import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/alert_dialog.dart';
import 'package:tourly/common/widgets/showToast.dart';
import 'package:tourly/controllers/auth_controller/data_user.dart';
import 'package:tourly/controllers/auth_controller/handle_user.dart';
import 'package:tourly/controllers/auth_controller/login_controller.dart';
import 'package:tourly/models/user_model.dart';

class SettingController extends GetxController {
  final box = GetStorage();
  RxBool isLoading = false.obs;
  final login = Get.put(LoginController());

  // Setting User
  late Rx<TextEditingController> fullNameController = TextEditingController().obs;
  late Rx<TextEditingController> emailController = TextEditingController().obs;
  late Rx<TextEditingController> phoneController = TextEditingController().obs;
  late Rx<TextEditingController> addressController = TextEditingController().obs;
  late Rx<TextEditingController> birthDayController = TextEditingController().obs;
  late Rx<DateTime> birthDayDateTime = DateTime.now().obs;
  RxString selectedSex = 'Nam'.obs;
  final formKeyInforUser = GlobalKey<FormState>();
  RxBool isChangeImage = false.obs;
  late File imageFile;

  //Setting Bot
  RxBool generateImage = false.obs;
  RxBool generateVoice = false.obs;
  RxString imageSource = 'Google'.obs;
  RxString selectedVoice = 'Google'.obs;
  late Rx<TextEditingController> keyAPIController = TextEditingController().obs;
  RxList<String> listKeysAPI = <String>[].obs;

  final List<String> chatChannel = ['ChatGPT'];
  RxInt selectedChatChannels = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getInforFirebase();
    keyAPIController.value.text = box.read('keyAPI') ?? '';
    generateImage.value = box.read('generateImage') ?? false;
    generateVoice.value = box.read('generateVoice') ?? false;
    imageSource.value = box.read('imageSource') ?? 'Google';
    selectedVoice.value = box.read('selectedVoice') ?? 'Google';
    selectedChatChannels.value = box.read('selectedChatChannels') ?? 0;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();

    fullNameController.value.dispose();
    emailController.value.dispose();
    phoneController.value.dispose();
    addressController.value.dispose();
    birthDayController.value.dispose();
  }

  Future<void> getInforFirebase() async {
    fullNameController.value.text = DataUser.userModel.value.fullName;
    emailController.value.text = DataUser.userModel.value.email;
    phoneController.value.text = DataUser.userModel.value.phoneNumber;
    addressController.value.text = DataUser.userModel.value.address;
    birthDayController.value.text = DataUser.userModel.value.birthDay;
    selectedSex.value = DataUser.userModel.value.sex;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('apiKeys').get();
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
      for (int i = 0; i < data!.length; i++) {
        if (data.containsKey('key$i')) {
          listKeysAPI.add(data['key$i']);
        }
      }
      if (data.length > 5) {
        chatChannel.removeAt(1);
      }
    }
    print('key: ${listKeysAPI.length}');
  }

  String randomKeyAPI() {
    var random = Random();
    int index = random.nextInt(listKeysAPI.length);
    print(listKeysAPI[index]);
    return listKeysAPI[index];
  }

  Future<void> chooseImage() async {
    PermissionStatus permissionStatus = PermissionStatus.denied;
    if (Platform.isIOS) {
      permissionStatus = await Permission.photos.request();
    } else if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      permissionStatus =
          deviceInfo.version.sdkInt < 33 ? await Permission.storage.request() : await Permission.photos.request();
    } else {
      permissionStatus = await Permission.photos.request();
    }

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        // Xử lý ảnh đã chọn tại đây
        imageFile = File(pickedImage.path);
        final Reference storageReference =
            FirebaseStorage.instance.ref().child('images/${DataUser.userModel.value.id}.jpg');
        final UploadTask uploadTask = storageReference.putFile(imageFile);
        await uploadTask;
        final String downloadURL = await storageReference.getDownloadURL();
        DataUser.userModel.value = UserModel(
          fullName: DataUser.userModel.value.fullName,
          email: DataUser.userModel.value.email,
          id: DataUser.userModel.value.id,
          imagePath: downloadURL,
          sex: DataUser.userModel.value.sex,
          phoneNumber: DataUser.userModel.value.phoneNumber,
          birthDay: DataUser.userModel.value.birthDay,
          address: DataUser.userModel.value.address,
          loginWith: DataUser.userModel.value.loginWith,
        );
        box.write('user', DataUser.userModel.value.toJson());
        await HandleUser().addInfoUser(DataUser.userModel.value);
      }
    } else if (permissionStatus.isPermanentlyDenied || permissionStatus.isLimited) {
      // Quyền truy cập vào thư viện ảnh bị từ chối vĩnh viễn
      // Hiển thị thông báo và hướng dẫn người dùng mở cài đặt ứng dụng
      ShowToast(text: 'Hãy cấp quyền mở thư viện ảnh!').show();
      await openAppSettings();
    }
  }

  selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  /// This builds material date picker in Android
  buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDayDateTime.value,
      firstDate: DateTime(1950),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null) birthDayDateTime.value = picked;
  }

  /// This builds cupertion date picker in iOS
  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: Get.size.height * 0.4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Text(
                            'Huỷ',
                            style: AppConst.style(18, AppConst.kTextColor),
                          )),
                      Text(
                        'Ngày sinh',
                        style: AppConst.style(18, AppConst.kTextColor, fontWeight: FontWeight.w600),
                      ),
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Text(
                            'Xong',
                            style: AppConst.style(18, AppConst.kPrimaryColor),
                          )),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 1,
                  color: AppConst.kSubTextColor,
                ),
                Container(
                  height: MediaQuery.of(context).copyWith().size.height / 3,
                  color: Colors.white,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (picked) {
                      if (picked != birthDayDateTime.value) {
                        birthDayDateTime.value = picked;
                        birthDayController.value.text = DateFormat('dd/MM/yyyy').format(birthDayDateTime.value);
                      }
                    },
                    initialDateTime: birthDayDateTime.value,
                    minimumYear: 1950,
                    maximumYear: 2025,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> signOut() async {
    try {
      box.erase();
      box.write('accessed_application', true);
      await login.signOut(context: Get.context!);
      await Get.deleteAll(force: true);
      Phoenix.rebirth(Get.context!);
      Get.reset();
    } catch (e) {
      print("Lỗi khi xoá tài khoản: $e");
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      // Lấy thông tin người dùng hiện tại
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Xoá tài khoản người dùng
        Get.dialog(const Center(child: CircularProgressIndicator()));
        await user.delete();

        // Xoá User Firestore
        if (DataUser.userModel.value.loginWith == 'phone') {
          DocumentReference documentReference =
              FirebaseFirestore.instance.collection('users').doc(DataUser.userModel.value.phoneNumber);
          documentReference.delete();
        } else {
          DocumentReference documentReference =
              FirebaseFirestore.instance.collection('users').doc(DataUser.userModel.value.email);
          documentReference.delete();
        }

        // Xoá Chat Firestore
        DocumentReference documentChat =
            FirebaseFirestore.instance.collection('chats').doc(DataUser.userModel.value.id);
        documentChat.delete();

        // Xoá Favorites Firestore
        DocumentReference documentFavorites =
            FirebaseFirestore.instance.collection('favorites').doc(DataUser.userModel.value.id);
        documentFavorites.delete();

        Get.back();
        await signOut();
        const ShowToast(text: 'Đã xoá tài khoản thành công').show();
      } else {
        Get.back();
        Get.dialog(AlertDialogCustom(
          notification: 'Vui lòng đăng nhập lại',
          onPress: () async {
            await signOut();
          },
        ));
      }
    } catch (e) {
      print("Lỗi khi xoá tài khoản: $e");
      Get.dialog(AlertDialogCustom(
        notification: 'Vui lòng đăng nhập lại',
        onPress: () async {
          await signOut();
        },
      ));
    }
  }
}
