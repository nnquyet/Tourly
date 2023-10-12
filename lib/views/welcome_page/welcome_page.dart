import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/name_divider.dart';
import 'package:tourly/common/widgets/rounded_button.dart';
import 'package:tourly/common/widgets/social_icon.dart';
import 'package:tourly/controllers/auth_controller/login_controller.dart';

import 'package:tourly/views/auth_page/login_page.dart';
import 'package:tourly/views/auth_page/sign_up_page.dart';

class Welcome extends StatelessWidget {
  Welcome({Key? key}) : super(key: key);
  final login = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppConst.kPrimaryLightColor,
      appBar: null,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/vietnam.jpeg',
                      width: size.width * 0.5,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  SizedBox(
                    width: size.width * 0.85,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: const [
                            TextSpan(
                              text: 'Chào mừng bạn đến với ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF141416),
                                decoration: TextDecoration.none,
                                height: 1.5,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextSpan(
                              text: 'Tourly',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppConst.kButtonColor,
                                decoration: TextDecoration.none,
                                height: 1.5,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    width: size.width * 0.85,
                    child: const Text(
                      'Ứng dụng hỗ trợ du lịch',
                      style: TextStyle(fontSize: 18, height: 1.25),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),
                  RoundedButton(
                    text: 'Đăng nhập',
                    press: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                  ),
                  RoundedButton(
                    text: 'Đăng ký',
                    color: Colors.white,
                    textColor: AppConst.kButtonColor,
                    press: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                  ),
                  SizedBox(height: size.height * 0.1),
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
                  )
                ],
              ),
            ),
          ),
          // isLoading
          //     ? Positioned.fill(
          //         child: Container(
          //           color: Colors.black.withOpacity(0.5),
          //           child: const Center(
          //             child: CircularProgressIndicator(),
          //           ),
          //         ),
          //       )
          //     : const Center(child: null),
        ],
      ),
    );
  }
}
