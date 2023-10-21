import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _HelpState();
}

class _HelpState extends State<SupportPage> with SingleTickerProviderStateMixin {
  int _selectedIndexBottomAppbar = 0;
  final List<String> questions = [
    'GLEAN là gì?',
    'GLEAN có miễn phí không?',
    'GLEAN có những tính năng gì?',
    'Kiểm tra mắt qua hình ảnh như thế nào?',
    'Model BHBot có gì đặc biệt?',
  ];

  final List<String> answers = [
    'GLEAN là một chương trình kết hợp với trí tuệ nhân tạo (AI) để tương tác với con người, giúp trả lời những câu hỏi một cách nhanh chóng.',
    'Có, GLEAN của chúng tôi hoàn toàn miễn phí',
    'GLEAN có thể:'
        '\n- Hỏi đáp và giải quyết vấn đề'
        '\n- Dịch và biên tập'
        '\n- Xử lý nhiều ngôn ngữ khác nhau'
        '\n- Kiểm tra mắt qua hình ảnh',
    'Bạn có thể gửi hình ảnh cho GLEAN bằng cách chụp ảnh hoặc chọn ảnh từ bộ sưu tập. Hãy nhớ cấp quyền trước khi chụp ảnh và chọn ảnh nhé!',
    'Model BHBot có thể trả lời các câu hỏi liên quan về mắt',
  ];

  late List<bool> _showAnswer;
  late AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showAnswer = List.filled(questions.length, false);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppConst.kPrimaryLightColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: AppConst.kPrimaryLightColor,
          elevation: 0,
          title: const Text('Trung tâm trợ giúp',
              style: TextStyle(color: AppConst.kTextColor, fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedIndexBottomAppbar = index;
              });
            },
            tabs: [
              Tab(
                child: Text('Câu hỏi thường gặp',
                    style: TextStyle(
                        fontSize: 16,
                        color: _selectedIndexBottomAppbar == 0 ? AppConst.kPrimaryColor : AppConst.kTextColor)),
              ),
              Tab(
                child: Text('Liên hệ',
                    style: TextStyle(
                        fontSize: 16,
                        color: _selectedIndexBottomAppbar == 1 ? AppConst.kPrimaryColor : AppConst.kTextColor)),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: TabBarView(
            children: [
              ListView.builder(
                itemCount: questions.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      questionAndAnswer(questions[index], answers[index], index),
                      SizedBox(height: size.height * 0.02)
                    ],
                  );
                },
              ),
              Column(
                children: [
                  buildContact(Icons.facebook_outlined, 'Facebook', () async {
                    if (!await launchUrl(Uri.parse('https://www.facebook.com/quyetnn.bvhn'))) {
                      throw Exception('Could not launch url}');
                    }
                  }),
                  // SizedBox(height: size.height * 0.02),
                  // buildContact(Icons.link, 'Website', () async {
                  //   if (!await launchUrl(Uri.parse('https://bachasoftware.com'))) {
                  //     throw Exception('Could not launch url}');
                  //   }
                  // }),
                  // SizedBox(height: size.height * 0.02),
                  // buildContact(Icons.phone, '+84 88 616 0880', () {}),
                  // SizedBox(height: size.height * 0.02),
                  // buildContact(Icons.email_outlined, 'hello@bachasoftware.com', () {}),
                  // SizedBox(height: size.height * 0.02),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget questionAndAnswer(String question, String answer, int index) {
    final bool isAnswerVisible = _showAnswer[index];
    return GestureDetector(
      onTap: () {
        final lengthQuestions = questions.length;
        setState(() {
          for (int i = 0; i < lengthQuestions; ++i) {
            if (i == index) {
              _showAnswer[i] = !_showAnswer[i];
            } else {
              _showAnswer[i] = false;
            }
          }
          if (isAnswerVisible) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: AppConst.kBotChatColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: isAnswerVisible
            ? SizeTransition(
                sizeFactor: _animationController,
                axisAlignment: -1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            question,
                            style: const TextStyle(fontSize: 18, color: AppConst.kTextColor),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_outlined, color: AppConst.kPrimaryLightColor),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1, height: 2),
                    const SizedBox(height: 10),
                    Text(answer, style: const TextStyle(fontSize: 16, color: Color(0xFF353945))),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(fontSize: 18, color: AppConst.kTextColor),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_outlined, color: AppConst.kTextColor),
                ],
              ),
      ),
    );
  }

  Widget buildContact(IconData icon, String contact, Function()? onPress) {
    return OutlinedButton(
      onPressed: onPress,
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          minimumSize: const Size(0, 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: AppConst.kPrimaryColor, size: 30),
          const SizedBox(width: 10.0),
          Text(contact, style: const TextStyle(fontSize: 18.0, color: AppConst.kTextColor)),
        ],
      ),
    );
  }
}
