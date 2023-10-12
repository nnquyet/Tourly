import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/name_divider.dart';
import 'package:tourly/common/widgets/rounded_button.dart';
import 'package:tourly/common/widgets/social_icon.dart';
import 'package:tourly/controllers/auth_controller/login_controller.dart';
import 'package:tourly/views/auth_page/login_page.dart';
import 'package:tourly/views/auth_page/verify_login_phone_screen.dart';

class LoginPhoneScreen extends StatefulWidget {
  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final login = Get.put(LoginController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          buildBackground(),
          buildLogo(),
          Container(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.125),
            height: size.height * 0.7,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppConst.kPrimaryLightColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppConst.kRadius * 1.5),
                topLeft: Radius.circular(AppConst.kRadius * 1.5),
              ),
            ),
            child: Form(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.08),
                    const Text(
                      "Vui lòng nhập số điện thoại!",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.06),
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: login.countryController.value,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, -2),
                            child: const Text(
                              "|",
                              style: TextStyle(fontSize: 33, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: TextField(
                            onChanged: (value) {
                              login.phoneNumber.value = value;
                            },
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Số điện thoại",
                            ),
                          ))
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    RoundedButton(
                      text: 'Gửi mã xác thực',
                      press: () async {
                        Get.dialog(const Center(child: CircularProgressIndicator()));
                        if (login.phoneNumber.value[0] == '0') {
                          login.phoneNumber.value = login.phoneNumber.value.substring(1);
                        }
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: login.countryController.value.text + login.phoneNumber.value,
                          verificationCompleted: (PhoneAuthCredential credential) async {
                            await FirebaseAuth.instance.signInWithCredential(credential);
                          },
                          verificationFailed: (FirebaseAuthException e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.check_box, color: Colors.white),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Số điện thoại không chính xác',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.redAccent,
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            login.verify.value = verificationId;
                            Get.back();
                            Get.to(() => const VerifyLoginPhone());
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {
                            login.verify.value = verificationId;
                          },
                          timeout: const Duration(seconds: 60),
                        );
                        Get.back();
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.off(() => LoginScreen());
                        },
                        child: const Text(
                          'Đăng nhập với email',
                          style: TextStyle(color: AppConst.kButtonColor, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.08),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildBackground() {
    Size size = Get.size;
    return Container(
      height: size.height,
      decoration: const BoxDecoration(
        gradient: AppConst.kGradient,
      ),
    );
  }

  Positioned buildLogo() {
    Size size = Get.size;
    return Positioned(
      top: 0,
      child: SizedBox(
        height: size.height * 0.35,
        child: Center(
          child: Image.asset(
            "assets/images/vietnam.jpeg",
            width: size.width * 0.45,
            height: size.width * 0.45,
          ),
        ),
      ),
    );
  }
}
