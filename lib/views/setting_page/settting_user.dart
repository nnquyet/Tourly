import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/services.dart';
import 'package:tourly/common/widgets/alert_dialog.dart';
import 'package:tourly/common/widgets/app_image.dart';

import '../../../common/widgets/rounded_button.dart';
import '../../../common/widgets/text_field_container.dart';
import '../../common/app_constants.dart';
import '../../controllers/auth_controller/data_user.dart';
import '../../controllers/auth_controller/handle_user.dart';
import '../../controllers/home_page_controller/setting_controller.dart';
import '../../models/user_model.dart';

class SettingUser extends StatelessWidget {
  SettingUser({super.key});

  final SettingController setting = Get.find();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Obx(
      () => Stack(
        children: [
          Scaffold(
            backgroundColor: AppConst.kPrimaryLightColor,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.black),
              backgroundColor: AppConst.kPrimaryLightColor,
              centerTitle: true,
              title: const Text(
                'Thông tin tài khoản',
                style: TextStyle(color: AppConst.kTextColor, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              elevation: 0,
              actions: [
                PopupMenuButton<String>(
                  offset: const Offset(0, 30),
                  onSelected: (value) {
                    // Xử lý khi một mục trong menu được chọn
                    if (value == 'option1') {
                      Get.dialog(AlertDialogCustom(
                        notification: 'Bạn có chắc muốn xoá tài khoản?',
                        onPress: () async {
                          await setting.deleteAccount(context);
                        },
                      ));
                    }
                    // else if (value == 'option2') {
                    // }
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'option1',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 8),
                            Text('Xoá tài khoản'),
                          ],
                        ),
                      ),
                      // const PopupMenuItem<String>(
                      //   value: 'option2',
                      //   child: Text('Tùy chọn 2'),
                      // ),
                    ];
                  },
                )
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.05),
              child: SingleChildScrollView(
                child: Form(
                  key: setting.formKeyInforUser,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          AppImage(
                            DataUser.userModel.value.imagePath,
                            size.width * 0.30,
                            size.width * 0.30,
                            circular: size.width * 0.15,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: GestureDetector(
                              onTap: () async {
                                await setting.chooseImage();
                              },
                              child: Container(
                                width: 32, // Điều chỉnh kích thước của biểu tượng tại đây
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.blue, // Màu nền xanh
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white, // Màu viền trắng
                                    width: 3.0, // Độ dày viền
                                  ),
                                ),
                                child: const Center(child: Icon(Icons.edit_outlined, color: Colors.white, size: 24)),
                              ),
                            ),
                          )
                        ],
                      ),
                      Text(DataUser.userModel.value.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                      SizedBox(height: size.height * 0.01),
                      DataUser.userModel.value.loginWith == 'phone'
                          ? Text(DataUser.userModel.value.phoneNumber)
                          : Text(DataUser.userModel.value.email),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Divider(thickness: 1)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFieldContainer(
                            hintText: 'Hãy nhập họ và tên',
                            onChanged: (value) {},
                            icon: Icons.circle,
                            iconColor: Colors.transparent,
                            obscureText: false,
                            controller: setting.fullNameController.value,
                            title: 'Họ và tên',
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Vui lòng nhập họ tên';
                              } else if (value.length < 3 || value.length > 50) {
                                return 'Họ và tên phải có độ dài từ 3 đến 50 ký tự';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: size.height * 0.035),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFieldContainer(
                                  readOnly: true,
                                  hintText: 'dd/mm/yyyy',
                                  onChanged: (value) {},
                                  icon: Icons.date_range,
                                  iconColor: AppConst.kPrimaryColor,
                                  obscureText: false,
                                  controller: setting.birthDayController.value,
                                  title: 'Ngày sinh',
                                  onClickIcon: () {
                                    setting.selectDate(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 30),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 9),
                                    const Text(
                                      'Giới tính',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    DropdownMenu<String>(
                                      initialSelection: setting.selectedSex.value,
                                      width: size.width * 0.41,
                                      dropdownMenuEntries: const [
                                        DropdownMenuEntry<String>(label: 'Nam', value: 'Nam'),
                                        DropdownMenuEntry<String>(label: 'Nữ', value: 'Nữ'),
                                      ],
                                      inputDecorationTheme:
                                          const InputDecorationTheme(constraints: BoxConstraints(maxHeight: 39)),
                                      onSelected: (value) {
                                        setting.selectedSex.value = value!;
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: size.height * 0.035),
                          DataUser.userModel.value.loginWith == 'phone'
                              ? TextFieldContainer(
                                  hintText: 'Hãy nhập email',
                                  onChanged: (value) {},
                                  icon: Icons.circle,
                                  iconColor: Colors.transparent,
                                  obscureText: false,
                                  controller: setting.emailController.value,
                                  title: 'Email',
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Vui lòng nhập email';
                                    }
                                    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                                    RegExp regex = RegExp(pattern);
                                    if (!regex.hasMatch(value)) {
                                      return 'Vui lòng nhập đúng định dạng email';
                                    }
                                    return null;
                                  },
                                )
                              : TextFieldContainer(
                                  hintText: 'Hãy nhập số điện thoại',
                                  onChanged: (value) {},
                                  icon: Icons.circle,
                                  iconColor: Colors.transparent,
                                  obscureText: false,
                                  controller: setting.phoneController.value,
                                  title: 'Số điện thoại',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly // Giới hạn chỉ cho phép nhập số
                                  ],
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Vui lòng nhập số điện thoại';
                                    } else if (value[0] != '0' || value.length != 10) {
                                      return 'Số điện thoại không hợp lệ';
                                    }
                                    return null;
                                  },
                                ),
                          SizedBox(height: size.height * 0.035),
                          TextFieldContainer(
                            hintText: 'Hãy nhập địa chỉ',
                            onChanged: (value) {},
                            icon: Icons.circle,
                            iconColor: Colors.transparent,
                            obscureText: false,
                            controller: setting.addressController.value,
                            title: 'Địa chỉ',
                          ),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          RoundedButton(
                            text: 'Cập nhật',
                            press: () async {
                              if (setting.formKeyInforUser.currentState!.validate()) {
                                setting.isLoading.value = true;

                                UserModel userModel = UserModel(
                                  fullName: setting.fullNameController.value.text,
                                  email: setting.emailController.value.text,
                                  id: DataUser.userModel.value.id,
                                  imagePath: DataUser.userModel.value.imagePath,
                                  sex: setting.selectedSex.value,
                                  phoneNumber: setting.phoneController.value.text,
                                  birthDay: setting.birthDayController.value.text,
                                  address: setting.addressController.value.text,
                                  loginWith: DataUser.userModel.value.loginWith,
                                );
                                DataUser.userModel.value = userModel;

                                setting.box.write('user', DataUser.userModel.value.toJson());
                                await HandleUser().addInfoUser(userModel);

                                setting.isLoading.value = false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.check_box, color: Colors.white),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Đã cập nhật thành công.',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.cyan,
                                    duration: Duration(milliseconds: 1500),
                                  ),
                                );
                                Get.back();
                              }
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (setting.isLoading.value)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
