import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/controllers/auth_controller/data_user.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class ChatMessage extends StatefulWidget {
  final String text;
  final bool isUser;
  bool isNewMessage;
  bool isDisplayTime;
  String time;

  ChatMessage(
      {super.key,
      required this.text,
      required this.isUser,
      required this.isNewMessage,
      required this.time,
      required this.isDisplayTime});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  var widthScreen;
  var heightScreen;
  late DateTime date;
  late String hour;
  SampleItem? selectedMenu;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.height;
    date = DateFormat('EEEE, yyyy MMMM d, h:mm a').parse(widget.time);
    hour = DateFormat('h:mm a').format(date);

    if (widget.isUser) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DataUser.userModel.value.fullName.split(' ').last,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(DataUser.userModel.value.imagePath),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: AppConst.kPrimaryColor,
                ),
                constraints: BoxConstraints(maxWidth: widthScreen * 0.7),
                margin: const EdgeInsets.only(top: 5),
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.text,
                        style: const TextStyle(fontSize: 17, color: Color(0xFFFFFFFF)),
                      ),
                      const TextSpan(
                        text: '\nz', // Khoảng trống nhỏ
                        style: TextStyle(fontSize: 5, color: AppConst.kPrimaryColor), // Điều chỉnh kích thước chữ
                      ),
                      TextSpan(
                        text: '\n$hour',
                        style: const TextStyle(fontSize: 14, color: Color(0xFFE6E8EC)),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.isDisplayTime == true)
                Text(
                  '$hour   ',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
            ],
          ),
        );
      });
    } else {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = widthScreen * 0.7;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/bot.png'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    Text(
                      'Bot',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: AppConst.kBotChatColor,
                  ),
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  margin: const EdgeInsets.only(top: 5),
                  child: widget.isNewMessage
                      ? AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              widget.text,
                              textStyle: const TextStyle(
                                fontSize: 17.0,
                              ),
                              speed: const Duration(milliseconds: 60),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                        )
                      : RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.text,
                                style: const TextStyle(fontSize: 17, color: Colors.black),
                              ),
                              const TextSpan(
                                text: '\nz', // Khoảng trống nhỏ
                                style:
                                    TextStyle(fontSize: 5, color: AppConst.kBotChatColor), // Điều chỉnh kích thước chữ
                              ),
                              TextSpan(
                                text: '\n$hour',
                                style: const TextStyle(fontSize: 14, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                ),
                if (widget.isDisplayTime == true)
                  Text(
                    '  $hour',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 15, color: AppConst.kTextColor),
                  ),
              ],
            ),
          );
        },
      );
    }
  }
}
