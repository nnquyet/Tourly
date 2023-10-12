import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/rounded_button.dart';
import 'package:tourly/controllers/auth_controller/login_controller.dart';

class VerifyLoginPhone extends StatefulWidget {
  const VerifyLoginPhone({Key? key}) : super(key: key);

  @override
  State<VerifyLoginPhone> createState() => _VerifyLoginPhoneState();
}

class _VerifyLoginPhoneState extends State<VerifyLoginPhone> {
  final login = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/vietnam.jpeg',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 45),
              const Text(
                "Nhập mã xác nhận",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                "Mã xác thực sẽ được gửi đến số điện thoại",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone),
                  const SizedBox(width: 5),
                  Text(
                    '(${login.countryController.value.text}) ${login.phoneNumber.value}',
                    style: AppConst.style(20, AppConst.kTextColor, fontWeight: FontWeight.w600),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                autofocus: true,
                showCursor: true,
                onChanged: (value) {
                  login.code.value = value;
                },
                onCompleted: (pin) => print(pin),
              ),
              const SizedBox(height: 20),
              RoundedButton(
                text: 'Tiếp theo',
                press: () async {
                  try {
                    await login.signInWithPhoneNumber(context);
                  } catch (e) {
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.check_box, color: Colors.white),
                            SizedBox(width: 8.0),
                            Text(
                              'Mã xác thực không chính xác!',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(milliseconds: 1500),
                      ),
                    );
                  }
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(
                      "Edit Phone Number ?",
                      style: TextStyle(color: AppConst.kPrimaryColor),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
