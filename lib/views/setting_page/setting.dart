import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/app_image.dart';
import 'package:tourly/common/widgets/showToast.dart';

import '../../common/widgets/alert_dialog.dart';
import '../../controllers/auth_controller/data_user.dart';
import '../../controllers/auth_controller/login_controller.dart';
import '../../controllers/home_page_controller/setting_controller.dart';
import 'setting_bot.dart';
import 'settting_user.dart';

class Setting extends StatelessWidget {
  Setting({super.key});

  final SettingController setting = Get.find();
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Obx(
      () => Scaffold(
        backgroundColor: AppConst.kPrimaryLightColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.black54),
          backgroundColor: AppConst.kPrimaryLightColor,
          elevation: 0,
          title: const Text(
            'Cài đặt',
            style: TextStyle(color: AppConst.kTextColor, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppImage(
                  DataUser.userModel.value.imagePath,
                  size.width * 0.30,
                  size.width * 0.30,
                  circular: size.width * 0.15,
                ),
                SizedBox(height: size.height * 0.01),
                Text(DataUser.userModel.value.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                SizedBox(height: size.height * 0.01),
                DataUser.userModel.value.loginWith == 'phone'
                    ? Text(DataUser.userModel.value.phoneNumber)
                    : Text(DataUser.userModel.value.email),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Divider(thickness: 1)),
                InkWell(
                  onTap: () {
                    Get.to(() => SettingUser());
                  },
                  child: buildSettingOption(context, 'Thông tin tài khoản', icon: Icons.person_outline),
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => SettingBot());
                  },
                  child: buildSettingOption(context, 'Cài đặt Bot', icon: Icons.android_outlined),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Divider(thickness: 1)),
                Container(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: InkWell(
                    onTap: () {
                      Get.dialog(AlertDialogCustom(
                        notification: 'Bạn có chắc muốn đăng xuất?',
                        onPress: () async {
                          await setting.signOut();
                          const ShowToast(text: 'Đăng xuất thành công').show();
                        },
                      ));
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout_outlined),
                        SizedBox(width: 15),
                        Expanded(
                          child:
                              Text('Đăng xuất', style: TextStyle(fontSize: 18, color: Color.fromRGBO(20, 20, 22, 1))),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildSettingOption(BuildContext context, String title,
      {IconData? icon, bool isSwitch = false, String? subtitle, Widget? switchSetting}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      child: Row(
        children: [
          if (icon != null) Icon(icon),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppConst.style(AppConst.kFontSize * 1.1, const Color.fromRGBO(20, 20, 22, 1))),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      subtitle,
                      style: const TextStyle(fontSize: 15, color: Color.fromRGBO(59, 59, 65, 1.0)),
                      softWrap: true,
                    ),
                  ),
              ],
            ),
          ),
          isSwitch
              ? switchSetting!
              : const Padding(
                  padding: EdgeInsets.only(right: 10), child: Icon(Icons.arrow_forward_ios_outlined, size: 18)),
        ],
      ),
    );
  }
}
