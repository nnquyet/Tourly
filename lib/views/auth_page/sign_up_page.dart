import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/name_divider.dart';
import 'package:tourly/common/widgets/rounded_button.dart';
import 'package:tourly/common/widgets/social_icon.dart';
import 'package:tourly/common/widgets/text_field_container.dart';
import 'package:tourly/controllers/auth_controller/login_controller.dart';
import 'package:tourly/controllers/auth_controller/sign_up_controller.dart';
import 'package:tourly/views/auth_page/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final signup = Get.put(SignupController());
  final login = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Obx(
      () => Scaffold(
        backgroundColor: AppConst.kPrimaryLightColor,
        appBar: AppBar(
          title: const Text('Đăng ký', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: AppConst.kPrimaryLightColor,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.05),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: signup.formKeySignUp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFieldContainerAuth(
                      title: 'Họ và tên',
                      hintText: 'Nguyễn Văn A',
                      controller: signup.fullNameController,
                      onChanged: (value) {},
                      obscureText: false,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        } else if (!RegExp(
                                r"^[a-zA-Z\sáàảãạéèẻẽẹíìỉĩịóòỏõọúùủũụýỳỷỹỵăắằẳẵặâấầẩẫậđêếềểễệôốồổỗộơớờởỡợưứừửữự]+$")
                            .hasMatch(value)) {
                          return 'Họ và tên chỉ được chứa ký tự chữ cái và khoảng trắng';
                        } else if (value.length < 3 || value.length > 50) {
                          return 'Họ và tên phải có độ dài từ 3 đến 50 ký tự';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    TextFieldContainerAuth(
                      title: 'Email',
                      hintText: 'example@gmail.com',
                      controller: signup.usernameController,
                      onChanged: (value) {},
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
                      controller: signup.passwordController,
                      onChanged: (value) {},
                      icon: signup.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      iconColor: AppConst.kButtonColor,
                      obscureText: !signup.isPasswordVisible.value,
                      onClickIcon: () {
                        signup.isPasswordVisible.value = !signup.isPasswordVisible.value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 8) {
                          return 'Mật khẩu phải có ít nhất 8 ký tự';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Mật khẩu phải chứa ít nhất một ký tự chữ cái viết hoa';
                        }
                        if (!value.contains(RegExp(r'[a-z]'))) {
                          return 'Mật khẩu phải chứa ít nhất một ký tự chữ cái thường';
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'Mật khẩu phải chứa ít nhất một ký tự số';
                        }
                        if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                          return 'Mật khẩu phải chứa ít nhất một ký tự đặc biệt';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    TextFieldContainerAuth(
                      title: 'Xác nhận mật khẩu',
                      hintText: 'Xác nhận mật khẩu',
                      controller: signup.confirmPassController,
                      onChanged: (value) {},
                      icon: signup.isPasswordConfirmVisible.value ? Icons.visibility : Icons.visibility_off,
                      iconColor: AppConst.kButtonColor,
                      obscureText: !signup.isPasswordConfirmVisible.value,
                      onClickIcon: () {
                        signup.isPasswordConfirmVisible.value = !signup.isPasswordConfirmVisible.value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Vui lòng nhập xác thực mật khẩu';
                        } else if (value != signup.passwordController.text) {
                          return 'Xác thực mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    TextButton(
                      clipBehavior: Clip.none,
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(0)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        signup.isAgreedToPrivacyPolicy.value = !signup.isAgreedToPrivacyPolicy.value;
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 15,
                            width: 15,
                            child: Checkbox(
                              value: signup.isAgreedToPrivacyPolicy.value,
                              activeColor: AppConst.kButtonColor,
                              onChanged: (value) {
                                signup.isAgreedToPrivacyPolicy.value = value!;
                              },
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 16, color: Colors.black, height: 1.5),
                                  children: [
                                    TextSpan(text: 'Tôi đồng ý với '),
                                    TextSpan(
                                      text: 'Chính sách riêng tư',
                                      style: TextStyle(
                                        color: AppConst.kButtonColor,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          // Xử lý khi người dùng bấm vào "Chính sách quyền riêng tư"
                                          if (!await launchUrl(
                                              Uri.parse('https://sites.google.com/view/glean-bhsoft'))) {
                                            throw Exception('Could not launch url}');
                                          }
                                        },
                                    ),
                                    TextSpan(text: ' và '),
                                    TextSpan(
                                      text: 'Điều khoản sử dụng ứng dụng và dịch vụ',
                                      style: TextStyle(
                                        color: AppConst.kButtonColor,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          // Xử lý khi người dùng bấm vào "Chính sách quyền riêng tư"
                                          if (!await launchUrl(
                                              Uri.parse('https://sites.google.com/view/glean-bhsoft'))) {
                                            throw Exception('Could not launch url}');
                                          }
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),
                    RoundedButton(
                        text: 'Đăng ký',
                        press: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (signup.formKeySignUp.currentState!.validate()) {
                            if (signup.isAgreedToPrivacyPolicy.value) {
                              Get.dialog(const Center(child: CircularProgressIndicator()));

                              await signup.createUserWithEmailAndPassword(
                                  signup.usernameController.text, signup.passwordController.text, context);
                              FirebaseAuth.instance.currentUser?.sendEmailVerification();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.error_outline, color: Colors.white),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Vui lòng đồng ý với chính sách và điều khoản.',
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
                        }),
                    SizedBox(height: size.height * 0.03),
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
                    SizedBox(height: size.height * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Đã có tài khoản? ", style: TextStyle(color: AppConst.kTextColor)),
                        GestureDetector(
                          onTap: () {
                            Get.off(LoginScreen());
                          },
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              color: AppConst.kButtonColor,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
