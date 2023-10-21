import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tourly/controllers/auth_controller/handle_user.dart';
import 'package:tourly/models/user_model.dart';
import 'package:tourly/views/auth_page/login_page.dart';

class SignupController extends GetxController {
  final box = GetStorage();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final formKeySignUp = GlobalKey<FormState>();

  RxBool isPasswordVisible = false.obs;
  RxBool isPasswordConfirmVisible = false.obs;
  RxBool isAgreedToPrivacyPolicy = false.obs;

  late TextEditingController fullNameController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPassController;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fullNameController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPassController = TextEditingController();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
  }

  Future<void> createUserWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = firebaseAuth.currentUser;

      //clear tài khoản và mật khẩu đã lưu ở màn hình Login
      box.remove('username');
      box.remove('password');

      if (user != null) {
        final Reference storageReference = FirebaseStorage.instance.ref().child('images/${user.uid}.jpg');

        // Tải hình ảnh từ URL trực tiếp lên Firebase Storage
        final http.Response response =
            await http.get(Uri.parse('https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'));
        final Uint8List imageData = response.bodyBytes;
        final UploadTask uploadTask = storageReference.putData(imageData);
        await uploadTask;

        // Lấy đường dẫn tới tệp hình ảnh sau khi tải lên thành công
        final String downloadURL = await storageReference.getDownloadURL();

        UserModel userModel = UserModel(
          fullName: fullNameController.text,
          email: usernameController.text,
          id: user.uid,
          imagePath: downloadURL,
          sex: '',
          phoneNumber: '',
          birthDay: '',
          address: '',
          loginWith: 'email',
        );
        await HandleUser().addInfoUser(userModel);
      }
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.check_box, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Đã tạo tài khoản thành công.\nVui lòng kiểm tra email để xác thực tài khoản',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.cyan,
          duration: Duration(seconds: 5),
        ),
      );
      Get.off(() => LoginScreen());
    } on FirebaseAuthException catch (e) {
      Get.back();
      if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Địa chỉ email không hợp lệ.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Địa chỉ email này đã tồn tại.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Mật khẩu không đủ mạnh.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
