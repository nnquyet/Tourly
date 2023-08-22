import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tourly/controllers/auth_controller/hadleUser.dart';
import 'package:tourly/models/user_model.dart';
import 'package:tourly/views/auth_page/login_page.dart';
import 'package:tourly/views/home_page.dart';

class SignupController extends GetxController {
  final box = GetStorage();
  final formKeySignUp = GlobalKey<FormState>();
  Rx<bool> passwordVisible = false.obs;
  Rx<bool> passwordConfirmVisible = false.obs;
  Rx<bool> isAgreedToPrivacyPolicy = false.obs;
  Rx<bool> regSuccess = false.obs;

  late TextEditingController fullNameController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPassController;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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

  Future<void> onPressSignupButton() async {
    if (formKeySignUp.currentState!.validate()) {
      // regSuccess.value ? Get.snackbar("Thông báo", "Đăng ký thành công") : Get.snackbar("Lỗi", notification);
      // if (regSuccess.value) {
      //   Get.offAll(LoginScreen());
      // }
    }
  }

  Future<void> createUserWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = firebaseAuth.currentUser;
      UserModel? userModel;
      userModel?.fullName = fullNameController.text;

      //clear tài khoản và mật khẩu đã lưu ở màn hình Login
      box.remove('username');
      box.remove('password');
      await HandleUser()
          .addInfoUser(fullNameController.text, usernameController.text, user!.uid, '', '', '', '', imageFile: null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.check_box, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Đã tạo tài khoản thành công.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.cyan,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } on FirebaseAuthException catch (e) {
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
