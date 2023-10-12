import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/app_constants.dart';
import '../../controllers/home_page_controller/setting_controller.dart';

class SettingBot extends StatelessWidget {
  SettingBot({super.key});

  final SettingController setting = Get.find();

  // String myApikey = MyData.myApiKey ?? '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Obx(
      () => Scaffold(
        backgroundColor: AppConst.kPrimaryLightColor,
        appBar: AppBar(
          title: const Text('Bot',
              style: TextStyle(color: AppConst.kTextColor, fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppConst.kPrimaryLightColor,
          iconTheme: const IconThemeData(color: Color.fromRGBO(20, 20, 22, 1)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // buildOptionSetting(
                //   'Key OpenAI',
                //   'Vui lòng làm theo hướng dẫn để nhập Key OpenAI của bạn vào đây',
                //   optionSetting: const SizedBox.shrink(),
                // ),
                // SizedBox(height: size.height * 0.02),
                // buildTextFiledApiKey(context),
                // const Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Divider(thickness: 1)),
                buildOptionSetting(
                  'Gợi ý hình ảnh',
                  'Cho phép ứng dụng gửi trả về hình ảnh đi kèm câu trả lời',
                  isSwitch: true,
                  switchSetting: Switch(
                    value: setting.generateImage.value,
                    onChanged: (value) async {
                      setting.generateImage.value = value;
                      setting.box.write("generateImage", value);
                    },
                  ),
                  optionSetting: setting.generateImage.value
                      ? SizedBox(
                          width: 100,
                          child: DropdownButton(
                            value: setting.imageSource.value,
                            isExpanded: true,
                            onChanged: (value) async {
                              setting.imageSource.value = value!;
                              setting.box.write("imageSource", value);
                            },
                            items: ['Google'].map((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Divider(thickness: 1)),
                buildOptionSetting(
                  'Giọng đọc',
                  'Chọn giọng đọc mà bạn muốn bot trả lời',
                  isSwitch: true,
                  switchSetting: Switch(
                    value: setting.generateVoice.value,
                    onChanged: (value) async {
                      setting.generateVoice.value = value;
                      setting.box.write("generateVoice", value);
                    },
                  ),
                  optionSetting: setting.generateVoice.value
                      ? Platform.isAndroid
                          ? SizedBox(
                              width: 100,
                              child: DropdownButton(
                                  value: setting.selectedVoice.value,
                                  isExpanded: true,
                                  items: [
                                    'Google',
                                    'Linh San',
                                    'Ban Mai',
                                    'Lan Nhi',
                                    'Lê Minh',
                                    'Mỹ An',
                                    'Thu Minh',
                                    'Gia Huy'
                                  ].map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    setting.selectedVoice.value = value!;
                                    setting.box.write("selectedVoice", value);
                                  }),
                            )
                          : SizedBox(
                              width: 100,
                              child: DropdownButton(
                                  value: setting.selectedVoice.value,
                                  isExpanded: true,
                                  items: [
                                    'Google',
                                  ].map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    setting.selectedVoice.value = value!;
                                    setting.box.write("selectedVoice", value);
                                  }),
                            )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOptionSetting(String title, String subtitle,
      {bool isSwitch = false, Widget? switchSetting, Widget? optionSetting}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, color: AppConst.kTextColor, fontWeight: FontWeight.w500),
                softWrap: true, // Áp dụng softWrap cho Text
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 15, color: AppConst.kSubTextColor),
                  softWrap: true, // Áp dụng softWrap cho Text
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            optionSetting!,
            if (isSwitch) switchSetting!,
          ],
        )
      ],
    );
  }

  Widget buildTextFiledApiKey(BuildContext context) {
    return TextFormField(
      controller: setting.keyAPIController.value,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        prefixIcon: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                  title: const Text('Hướng dẫn lấy key OpenAI', textAlign: TextAlign.center),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '- Truy cập và đăng nhập trang: ',
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('https://platform.openai.com/account/api-keys')),
                        child: const Text(
                          'https://platform.openai.com/account/api-keys',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const Text(
                        '\n- Chọn \'Create new secret key\'\n\n- Copy key mới tạo và dán vào đây',
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.info_outline_rounded),
        ),
        suffixIcon: GestureDetector(
            onTap: () async {
              if (FocusScope.of(context).hasFocus) {
                // Nếu có, hủy focus và ẩn bàn phím
                FocusScope.of(context).unfocus();
              }
              setting.box.write("keyAPI", setting.keyAPIController.value.text);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.check_box, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text(
                        'Đã cập nhật thành công',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.cyan,
                  duration: Duration(milliseconds: 1500),
                ),
              );
            },
            child: const Icon(Icons.check)),
        hintText: 'Nhập Key OpenAI',
        contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
