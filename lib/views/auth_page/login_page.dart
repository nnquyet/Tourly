import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/alert_dialog.dart';
import 'package:tourly/common/widgets/name_divider.dart';
import 'package:tourly/common/widgets/rounded_button.dart';
import 'package:tourly/common/widgets/social_icon.dart';
import 'package:tourly/common/widgets/text_field_container.dart';
import 'package:tourly/controllers/auth_controller/login_controller.dart';
import 'package:tourly/views/auth_page/login_phone_screen.dart';
import 'package:tourly/views/auth_page/sign_up_page.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final login = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Obx(() => Scaffold(
          backgroundColor: AppConst.kPrimaryLightColor,
          appBar: AppBar(
            elevation: 0,
            title: const Text('Đăng nhập', style: TextStyle(color: Colors.black)),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: AppConst.kPrimaryLightColor,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.05),
            child: SingleChildScrollView(
              child: Form(
                key: login.formKeySignIn,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/vietnam.jpeg',
                        width: size.width * 0.5,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    TextFieldContainerAuth(
                      title: 'Email',
                      hintText: 'example@gmail.com',
                      controller: login.usernameController,
                      onChanged: (value) {},
                      icon: Icons.circle,
                      iconColor: Colors.transparent,
                      obscureText: false,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                        RegExp regex = new RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Vui lòng nhập đúng định dạng email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    TextFieldContainerAuth(
                      title: 'Mật khẩu',
                      hintText: 'Mật khẩu',
                      controller: login.passwordController,
                      onChanged: (value) {},
                      icon: login.passwordVisible.value ? Icons.visibility : Icons.visibility_off,
                      iconColor: AppConst.kButtonColor,
                      obscureText: !login.passwordVisible.value,
                      onClickIcon: () {
                        login.passwordVisible.value = !login.passwordVisible.value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    InkWell(
                      onTap: () {
                        login.isRememberLogin.value = !login.isRememberLogin.value;
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 15,
                            height: 15,
                            margin: const EdgeInsets.only(right: 10),
                            child: Checkbox(
                              value: login.isRememberLogin.value,
                              activeColor: AppConst.kButtonColor,
                              onChanged: (bool? value) {
                                login.isRememberLogin.value = value!;
                              },
                            ),
                          ),
                          Text('Ghi nhớ', style: TextStyle(color: AppConst.kTextColor)),
                          Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),
                    RoundedButton(
                      text: 'Đăng nhập',
                      press: () async {
                        if (login.formKeySignIn.currentState!.validate()) {
                          await login.signInWithEmailAndPassword(context);
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Get.dialog(
                                AlertDialogCustom(
                                  notification: "Quên mật khẩu",
                                  children2: Form(
                                    key: login.formKeyForgetPassword,
                                    child: TextFieldContainerAuth(
                                      title: 'Email',
                                      hintText: "example@gmail.com",
                                      onChanged: (value) {},
                                      controller: login.usernameController,
                                      // prefixIcon: Icons.email_outlined,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Vui lòng nhập email';
                                        }
                                        String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                                        RegExp regex = new RegExp(pattern);
                                        if (!regex.hasMatch(value)) {
                                          return 'Vui lòng nhập đúng định dạng email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  onPress: () {
                                    if (login.formKeyForgetPassword.currentState!.validate()) {
                                      Get.dialog(const Center(child: CircularProgressIndicator()));
                                      FirebaseAuth.instance
                                          .sendPasswordResetEmail(email: login.usernameController.text)
                                          .catchError((onError) => print('Error sending email verification $onError'))
                                          .then(
                                        (value) {
                                          Get.back();
                                          Get.back();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(Icons.check_box, color: Colors.white),
                                                  SizedBox(width: 8.0),
                                                  Flexible(
                                                    child: Text(
                                                      'Hãy kiểm tra email để lấy lại mật khẩu',
                                                      style: TextStyle(color: Colors.white),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.cyan,
                                              duration: Duration(seconds: 5),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                            child: const Text('Quên mật khẩu?',
                                style: TextStyle(color: AppConst.kButtonColor, fontWeight: FontWeight.w400))),
                        TextButton(
                            onPressed: () {
                              Get.off(() => LoginPhoneScreen());
                            },
                            child: const Text('Đăng nhập với SMS',
                                style: TextStyle(color: AppConst.kButtonColor, fontWeight: FontWeight.w400))),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    const NameDivider(text: 'Hoặc tiếp tục với'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialIcon(iconSrc: 'assets/images/facebook.png', press: () {}),
                        SocialIcon(
                            iconSrc: 'assets/images/google.png',
                            press: () {
                              login.signInWithGoogle(context: context);
                            }),
                        SocialIcon(iconSrc: 'assets/images/github.png', press: () {})
                      ],
                    ),
                    SizedBox(height: size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Chưa có tài khoản ? ", style: TextStyle(color: AppConst.kTextColor)),
                        GestureDetector(
                          onTap: () {
                            Get.off(SignupScreen());
                          },
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(
                              color: AppConst.kButtonColor,
                              decorationThickness: 2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
