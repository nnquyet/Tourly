import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/alert_dialog.dart';
import 'package:tourly/common/widgets/showToast.dart';
import 'package:tourly/common/widgets/three_dot.dart';
import 'package:tourly/controllers/home_page_controller/chat_controller.dart';
import 'package:tourly/controllers/home_page_controller/setting_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'chat_item.dart';
import 'round_checkbox.dart';

class Chat extends StatelessWidget {
  Chat({super.key});

  final SettingController setting = Get.find();
  final chat = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      chat.time.value = DateFormat('EEEE, yyyy MMMM d, h:mm a').format(DateTime.now());

      var keyboardVisibilityController = KeyboardVisibilityController();
      chat.keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
        if (!visible) {
          chat.showQuestionsSuggest.value = true;
          chat.showImagesSuggest.value = true;
          chat.displayIconCompose.value = true;
          chat.display.value = true;
        } else {
          chat.showQuestionsSuggest.value = false;
          chat.showImagesSuggest.value = false;
          chat.displayIconCompose.value = false;
          chat.display.value = false;
        }
      });
      return WillPopScope(
        onWillPop: () async {
          if (chat.isChooseMany.value) {
            chat.isChooseMany.value = false;
          } else if (chat.switchType.value) {
            Get.back();
          } else {
            chat.switchType.value = true;
          }
          chat.textToSpeech.stop();
          chat.audioPlayer.stop();
          return false;
        },
        child: GestureDetector(
          onTap: () {
            chat.focusNode.unfocus();
          },
          child: Scaffold(
            backgroundColor: AppConst.kPrimaryLightColor,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
              backgroundColor: AppConst.kPrimaryLightColor,
              centerTitle: true,
              title: const Text(
                'Chatbot',
                style: TextStyle(color: AppConst.kTextColor, fontSize: 18, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!chat.switchType.value)
                  Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: chat.videoPlayerController.value.isInitialized
                                  ? SizedBox(
                                      width: chat.size.value.width * chat.videoPlayerController.value.aspectRatio,
                                      height: chat.size.value.height,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: chat.videoPlayerController.value.size.width,
                                          height: chat.videoPlayerController.value.size.height,
                                          child: VideoPlayer(chat.videoPlayerController),
                                        ),
                                      ),
                                    )
                                  : const CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Expanded(child: Center()),
                          if (chat.questionScreenBot.value != '') _buildTextQuestion(),
                          _buildTextComposer(context),
                        ],
                      )
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chat.isChooseMany.value)
                        GestureDetector(
                          onTap: () {
                            chat.isChooseAll.value = !chat.isChooseAll.value;
                            if (chat.isChooseAll.value) {
                              chat.selectedMessage.value = chat.selectedMessage.map((value) => true).toList();
                            } else {
                              chat.selectedMessage.value = chat.selectedMessage.map((value) => false).toList();
                            }
                          },
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 18, right: 12),
                                    child: RoundCheckBox(value: chat.isChooseAll.value),
                                  ),
                                  const Text("All", style: TextStyle(fontSize: 17)),
                                ],
                              ),
                              const Divider(height: 1, thickness: 1),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          controller: chat.scrollControllerListMess,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          reverse: true,
                          itemBuilder: (context, index) {
                            final message = chat.messagesList[index];
                            if (message is ChatMessage) {
                              if (message.text.contains("chatImages")) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ChatMessage(
                                      text: message.text.split("\n")[0],
                                      isUser: true,
                                      isNewMessage: false,
                                      time: message.time,
                                      isDisplayTime: false,
                                    ),
                                    GestureDetector(
                                      onLongPress: () {
                                        Get.bottomSheet(Container(
                                          color: Colors.white,
                                          child: ListTile(
                                            leading: const Icon(Icons.download),
                                            title: const Text("Tải ảnh về thiết bị"),
                                            minLeadingWidth: 0,
                                            onTap: () async {
                                              Get.back();
                                              Get.dialog(const Center(child: CircularProgressIndicator()));
                                              // await chat.download(message.text.split("\n")[1]);
                                              Get.back();
                                            },
                                          ),
                                        ));
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: message.text.split("\n")[1],
                                        height: 200,
                                        width: 200,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, string, dynamic) => Container(
                                          color: Colors.grey.shade300,
                                          child: const Center(child: Icon(Icons.error_outline_outlined)),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              // Đây là một tin nhắn
                              return Obx(() => Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      chat.isChooseMany.value
                                          ? GestureDetector(
                                              onTap: () {
                                                chat.selectedMessage[index] = !chat.selectedMessage[index];
                                              },
                                              child: RoundCheckBox(value: chat.selectedMessage[index]))
                                          : const SizedBox.shrink(),
                                      Expanded(
                                        child: GestureDetector(
                                          onLongPress: () {
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              backgroundColor: Colors.transparent,
                                              builder: (BuildContext context) {
                                                return buildBottomOption(message, context, index);
                                              },
                                            );
                                          },
                                          child: message,
                                        ),
                                      )
                                    ],
                                  ));
                            } else if (message.split(' ').length == 3) {
                              // Đây là một ngày
                              return Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child:
                                    Center(child: Text(message, style: const TextStyle(color: AppConst.kSubTextColor))),
                              );
                            } else {
                              return GestureDetector(
                                onLongPress: () {
                                  Get.bottomSheet(Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      leading: const Icon(Icons.download),
                                      title: const Text("Tải ảnh về thiết bị"),
                                      minLeadingWidth: 0,
                                      onTap: () async {},
                                    ),
                                  ));
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Image.file(
                                    File(message),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    frameBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      int? frame,
                                      bool wasSynchronouslyLoaded,
                                    ) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300, width: 1),
                                        ),
                                        child: child,
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          itemCount: chat.messagesList.length,
                        ),
                      ),
                      if (chat.messages.isNotEmpty && chat.messages.first.isUser) const ThreeDots(),
                      if (chat.resultUrls.length > 2 && chat.checkGenerateReply.value && chat.display.value) showUrls(),
                      if (chat.images[0] != '' && setting.generateImage.value) buildImage(context),
                      if (chat.showQuestionsSuggest.value &&
                          chat.checkGenerateReply.value &&
                          chat.checkGenerateQuestion.value)
                        buildQuestionsTopic(),
                      _buildTextComposer(context),
                    ],
                  ),
                if (chat.switchType.value && chat.messages.isNotEmpty && !chat.displaySuggestWhenScroll.value)
                  Positioned(
                    top: 0, // căn đỉnh trên cùng
                    child: viewTimeMessage(),
                  ),
                if (chat.isLoading.value)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Padding buildBottomOption(message, BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Padding(
        padding: EdgeInsets.only(bottom: chat.size.value.height * 0.1),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              message,
              Container(
                width: chat.size.value.width * 0.4,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up_alt_outlined, color: Color(0xFF0196FE), size: 30),
                    ),
                    const VerticalDivider(width: 2, thickness: 1, color: Color(0xFFE6E8EC)),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_down_alt_outlined, color: Color(0xFF777E90), size: 30),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 72,
                width: chat.size.value.width * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: (message as ChatMessage).text));
                          const ShowToast(text: 'Đã sao chép vào bộ nhớ tạm').show();
                          Navigator.pop(context);
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.copy, size: 25, color: Color(0xFF30B28C)),
                            SizedBox(height: 7),
                            Text("Sao chép", style: TextStyle(color: AppConst.kTextColor)),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 2, thickness: 1, color: Color(0xFFE6E8EC)),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          chat.isChooseMany.value = true;
                          Navigator.pop(context);
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.add_task_outlined, size: 25, color: Color(0xFF1F3D8B)),
                            SizedBox(height: 7),
                            Text("Chọn nhiều", style: TextStyle(color: AppConst.kTextColor)),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 2, thickness: 1, color: Color(0xFFE6E8EC)),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          List<ChatMessage> chooseManyMessage = [];
                          // final lengthMessageList = chat.messagesList.length;
                          // final lengthMessages = chat.messages.length;
                          final indexOfMessage = chat.messages.lastIndexOf(chat.messagesList[index] as ChatMessage);
                          if (indexOfMessage % 2 == 1) {
                            chooseManyMessage.add(chat.messages[indexOfMessage]);
                            chooseManyMessage.add(chat.messages[indexOfMessage - 1]);
                          }
                          if (indexOfMessage % 2 == 0 &&
                              !chooseManyMessage.contains(chat.messages[indexOfMessage + 1])) {
                            chooseManyMessage.add(chat.messages[indexOfMessage + 1]);
                            chooseManyMessage.add(chat.messages[indexOfMessage]);
                          }

                          chat.messages.remove(chooseManyMessage[0]);
                          chat.messages.remove(chooseManyMessage[1]);
                          chat.deleteMessage(context, chat.messages.reversed.toList());
                          Navigator.pop(context);
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.delete, size: 25, color: Color(0xFFDC362E)),
                            SizedBox(height: 7),
                            Text("Xóa", style: TextStyle(color: AppConst.kTextColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    List<Widget> showImages = [];
    double imageOpacity = chat.showImagesSuggest.value ? 1.0 : 0.0;

    for (int i = 0; i < 4; ++i) {
      showImages.add(
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: SizedBox(
                    width: chat.size.value.width * 0.8,
                    height: chat.size.value.width * 0.795,
                    child: CachedNetworkImage(
                      imageUrl: chat.images[i],
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => i == 0
                          ? CachedNetworkImage(
                              imageUrl: chat.images[i + 1],
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: chat.images[i - 1],
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                );
              },
            );
          },
          child: AnimatedContainer(
            padding: const EdgeInsets.only(right: 4),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 137 * imageOpacity,
            height: 137 * imageOpacity,
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              imageUrl: chat.images[i],
              errorWidget: (context, url, error) => i == 0
                  ? CachedNetworkImage(
                      imageUrl: chat.images[i + 1],
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: chat.images[i - 1],
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 273,
      margin: const EdgeInsets.only(left: 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: showImages,
        ),
      ),
    );
  }

  //build các câu hỏi gợi ý khi bấm vào chủ đề
  Container buildQuestionsTopic() {
    List<String> listQuestionsSuggest = List.filled(4, '');
    List<Widget> buttons = [];
    for (int i = 0; i < 4; ++i) {
      listQuestionsSuggest[i] = chat.suggestQuestion[i] != '' ? chat.suggestQuestion[i] : 'This is a suggest question';
      buttons.add(
        OutlinedButton(
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          onPressed: () async {
            // listKeywords.clear();
            chat.resultUrls.clear();
            chat.resultDomains.clear();
            chat.checkGenerateReply.value = false;
            chat.images[0] = '';
            chat.handleSubmitted(listQuestionsSuggest[i]);
          },
          child: Text(
            listQuestionsSuggest[i],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    // }

    return Container(
      margin: const EdgeInsets.only(top: 5),
      height: 90,
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Scrollbar(
          // scrollbarOrientation: ScrollbarOrientation.right,
          thumbVisibility: true,
          // controller: _scrollController,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buttons,
            ),
          ),
        ),
      ),
    );
  }

  //build các chủ đề được gợi ý
  // Widget buildTopicKeywords(List<String> keywords) {
  //   return SizedBox(
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 18),
  //       decoration: const BoxDecoration(
  //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //       ),
  //       constraints: BoxConstraints(maxWidth: chat.size.value.width * 0.7, minWidth: 70),
  //       child: Wrap(
  //         spacing: 8.0,
  //         runSpacing: -5,
  //         children: keywords.map((keyword) {
  //           if (keyword == 'Xem thêm') {
  //             return TextButton(
  //                 onPressed: () {
  //                   chat.searchInBrowser(chat.translatedTextImage.value);
  //                 },
  //                 child: Text(keyword));
  //           } else {
  //             return ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: const Color.fromRGBO(209, 219, 250, 1),
  //                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //               ),
  //               onPressed: () async {
  //                 // String result = await ApiChatBotServices.buildQuestions('$keyword của $translatedTextImage');
  //                 // handleQuestionReturn(result);
  //                 chat.handleSubmitted(keyword);
  //                 // chat.topic.value = keyword;
  //                 // chat.checkSuggestQuestions.value = true;
  //                 chat.showQuestionsSuggest.value = true;
  //                 // checkGenerateQuestion = true;
  //               },
  //               child: Text(keyword, style: const TextStyle(color: Color.fromRGBO(18, 59, 182, 1.0))),
  //             );
  //           }
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  Widget showUrls() {
    // List<Widget> domains = [
    //   const Padding(
    //     padding: EdgeInsets.only(left: 18),
    //     child: Text('Xem thêm:'),
    //   )
    // ];
    //
    // for (int i = 0; i < 2; i++) {
    //   domains.add(
    //     Padding(
    //       padding: const EdgeInsets.only(left: 18.0),
    //       child: TextButton(
    //         onPressed: () async {
    //           if (!await launchUrl(Uri.parse(chat.resultUrls[i]))) {
    //             throw Exception('Could not launch ${chat.resultUrls[i]}');
    //           }
    //         },
    //         child: Text(chat.resultDomains[i]),
    //       ),
    //     ),
    //   );
    // }
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 18, right: 10, top: 15),
            child: Text('Xem thêm:', style: TextStyle(color: Color(0xFF777E90))),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () async {
                  if (!await launchUrl(Uri.parse(chat.resultUrls[0]))) {
                    throw Exception('Could not launch ${chat.resultUrls[0]}');
                  }
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(text: '1. ', style: TextStyle(color: AppConst.kTextColor)),
                      TextSpan(
                        text: chat.resultDomains[0],
                        style: const TextStyle(decoration: TextDecoration.underline, color: AppConst.kTextColor),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () async {
                  if (!await launchUrl(Uri.parse(chat.resultUrls[1]))) {
                    throw Exception('Could not launch ${chat.resultUrls[1]}');
                  }
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(text: '2. ', style: TextStyle(color: AppConst.kTextColor)),
                      TextSpan(
                        text: chat.resultDomains[1],
                        style: const TextStyle(decoration: TextDecoration.underline, color: AppConst.kTextColor),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget viewTimeMessage() {
    DateTime date = DateFormat('EEEE, yyyy MMMM d, h:mm a').parse(chat.messages[chat.indexCurrent.value].time);
    String day = DateFormat('EEEE, MMMM d').format(date);
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppConst.kBotChatColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.only(top: 10),
        child: Text(
          day,
          style: const TextStyle(color: AppConst.kSubTextColor),
        ),
      ),
    );
  }

  _showDialogVoice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () {
          chat.textEditingController.text = chat.textSpeech.value;
          chat.checkPop.value = false;
          chat.isListening.value = false;
          chat.speechToText.stop();
        },
        child: WillPopScope(
          onWillPop: () async {
            chat.textEditingController.text = chat.textSpeech.value;
            chat.checkPop.value = false;
            chat.isListening.value = false;
            chat.speechToText.stop();
            return true;
          },
          child: AlertDialog(
            title: const Text(
              'Hãy nói gì đó',
              textAlign: TextAlign.center,
            ),
            content: AvatarGlow(
              glowColor: Colors.blue,
              endRadius: 90.0,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              repeatPauseDuration: const Duration(milliseconds: 100),
              child: Material(
                // Replace this child with your own
                elevation: 8.0,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  radius: 35.0,
                  child: SizedBox(
                    width: 500,
                    height: 500,
                    child: IconButton(
                      icon: const Icon(Icons.mic),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        Navigator.of(context).pop();
                        chat.textEditingController.text = chat.textSpeech.value;
                        chat.checkPop.value = false;
                        chat.isListening.value = false;
                        chat.speechToText.stop();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextQuestion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [],
          ),
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: chat.questionScreenBot.value));
              const ShowToast(text: 'Đã sao chép vào bộ nhớ tạm').show();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                color: Color.fromRGBO(242, 248, 248, 1),
              ),
              margin: const EdgeInsets.only(top: 5),
              child: Text(
                chat.questionScreenBot.value,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer(BuildContext context) {
    double imageOpacity = chat.displayIconCompose.value ? 1.0 : 0.0;

    return !chat.isChooseMany.value
        ? IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.white),
              margin: const EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 15),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 35 * imageOpacity,
                    child: IconButton(
                      icon: const Icon(Icons.location_on_outlined),
                      onPressed: () {
                        openFindWay(context);
                      },
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 35 * imageOpacity,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: () async {
                        await chat.openCamera();
                      },
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 35 * imageOpacity,
                    child: IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () async {
                        await chat.chooseImage();
                      },
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 35 * imageOpacity,
                    margin: const EdgeInsets.only(right: 5),
                    child: IconButton(
                      icon: const Icon(Icons.mic_none),
                      onPressed: () async {
                        _showDialogVoice(context);
                        if (!chat.isListening.value) {
                          bool available = await chat.speechToText.initialize(
                            onStatus: (result) {
                              print('onStatus: $result');
                              if (result == 'done' && chat.checkPop.value) {
                                Navigator.of(context).pop();
                                chat.textEditingController.text = chat.textSpeech.value;
                                chat.isListening.value = false;
                                chat.speechToText.stop();
                              }
                            },
                            onError: (result) => print('onError: $result'),
                          );
                          if (available) {
                            chat.checkPop.value = true;
                            chat.isListening.value = true;
                            chat.speechToText.listen(
                                localeId: 'vi_VN, en_US',
                                listenMode: ListenMode.confirmation,
                                onResult: (result) => chat.textSpeech.value = result.recognizedWords);
                          }
                        }
                      },
                    ),
                  ),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppConst.kBotChatColor,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextFormField(
                        focusNode: chat.focusNode,
                        style: const TextStyle(fontSize: 18),
                        controller: chat.textEditingController,
                        // onSubmitted: chat.handleSubmitted,
                        decoration: const InputDecoration.collapsed(hintText: "Aa"),
                        maxLines: 3,
                        minLines: 1,
                        autofocus: false,
                        cursorColor: const Color.fromRGBO(255, 153, 141, 1.0),
                      ),
                    ),
                  ),
                  chat.currentVideoIndex.value == 2
                      ? IconButton(
                          icon: const Icon(
                            Icons.stop_circle_outlined,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            chat.textToSpeech.stop();
                            chat.audioPlayer.stop();
                            if (chat.currentVideoIndex.value == 2) chat.switchVideo();
                            chat.checkGenerateReply.value = true;
                          })
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            chat.focusNode.unfocus();
                            if (chat.textEditingController.text != "") {
                              chat.handleSubmitted(chat.textEditingController.text);
                              chat.textSpeech.value = '';
                            }
                            chat.images[0] = '';
                            // listKeywords.clear();
                            chat.resultUrls.clear();
                            chat.resultDomains.clear();
                            chat.showQuestionsSuggest.value = false;
                            // suggestTopic = false;
                            chat.checkGenerateReply.value = false;
                          },
                        ),
                ],
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.only(top: 10),
            color: const Color(0xFFF4F5F6),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      List<String> chooseManyMessage = [];
                      final lengthMessageList = chat.messagesList.length;
                      for (int i = lengthMessageList - 1; i >= 0; --i) {
                        if (chat.messagesList[i] is ChatMessage && chat.selectedMessage[i]) {
                          final indexOfMessage = chat.messages.lastIndexOf(chat.messagesList[i]);
                          print('indexOfMessage: $indexOfMessage');
                          print('i: $i');
                          if (indexOfMessage % 2 == 1) {
                            chooseManyMessage.add((chat.messagesList[i] as ChatMessage).text);
                            chooseManyMessage.add((chat.messagesList[i - 1] as ChatMessage).text);
                          }
                          if (indexOfMessage % 2 == 0 &&
                              !chooseManyMessage.contains((chat.messagesList[i + 1] as ChatMessage).text)) {
                            chooseManyMessage.add((chat.messagesList[i + 1] as ChatMessage).text);
                            chooseManyMessage.add((chat.messagesList[i] as ChatMessage).text);
                          }
                        }
                      }
                      chat.shareMessagesWithEmail(context, chooseManyMessage);
                    },
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.share_outlined, size: 25, color: AppConst.kTextColor),
                        SizedBox(height: 7),
                        Text("Chia sẻ", style: TextStyle(color: AppConst.kTextColor)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialogCustom(
                            notification: "Bạn chắc chắn muốn xuất dữ liệu?",
                            children2: const Column(
                              children: [
                                Text("Chi tiết thống kê các hoạt động của bạn sẽ được xuất thành file dạng PDF."),
                                Text("Quá trình xuất dữ liệu có thể mất một vài phút."),
                                Text("Để xác nhận, bạn hãy nhấn click vào nút “Xác nhận” bên dưới."),
                              ],
                            ),
                            onPress: () async {
                              chat.isLoading.value = true;
                              await chat.createPDF(context);
                              chat.isChooseMany.value = false;
                              chat.isLoading.value = false;
                              Get.back();
                            },
                          );
                        },
                      );
                    },
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.import_export_outlined, size: 25, color: AppConst.kTextColor),
                        SizedBox(height: 7),
                        Text("Xuất file", style: TextStyle(color: AppConst.kTextColor)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      List<ChatMessage> chooseManyMessage = [];
                      final lengthMessageList = chat.messagesList.length;
                      // final lengthMessages = chat.messages.length;
                      print("selected: ${chat.selectedMessage.length} $lengthMessageList}");
                      for (int i = lengthMessageList - 1; i >= 0; --i) {
                        if (chat.messagesList[i] is ChatMessage && chat.selectedMessage[i]) {
                          final indexOfMessage = chat.messages.lastIndexOf(chat.messagesList[i] as ChatMessage);
                          print('indexOfMessage: $indexOfMessage');
                          print('i: $i');
                          if (indexOfMessage % 2 == 1) {
                            chooseManyMessage.add(chat.messagesList[i] as ChatMessage);
                            chooseManyMessage.add(chat.messagesList[i - 1] as ChatMessage);
                          }
                          if (indexOfMessage % 2 == 0 &&
                              !chooseManyMessage.contains(chat.messagesList[i + 1] as ChatMessage)) {
                            chooseManyMessage.add(chat.messagesList[i + 1] as ChatMessage);
                            chooseManyMessage.add(chat.messagesList[i] as ChatMessage);
                          }
                        }
                      }

                      // for (int i = lengthMessages - 1; i >= 0; --i) {
                      //   if (chat.messagesList.contains(chat.messages[i] as dynamic) &&
                      //       !selectedMessage[chat.messagesList.lastIndexOf(chat.messages[i] as dynamic)]) {
                      //     print("dieukien1");
                      //     if (i % 2 == 1 && !chooseManyMessage.contains(chat.messages[i])) {
                      //       chooseManyMessage.add(chat.messages[i]);
                      //       chooseManyMessage.add(chat.messages[i - 1]);
                      //       print("dieukien2");
                      //     }
                      //     if (i % 2 == 0 && !chooseManyMessage.contains(chat.messages[i + 1])) {
                      //       chooseManyMessage.add(chat.messages[i + 1]);
                      //       chooseManyMessage.add(chat.messages[i]);
                      //       print("dieukien3");
                      //     }
                      //   }
                      // }
                      chat.deleteMessage(
                          context,
                          chat.messages
                              .where((element) => !chooseManyMessage.contains(element))
                              .toList()
                              .reversed
                              .toList());
                    },
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 7),
                        Icon(Icons.delete_outline_rounded, size: 25, color: AppConst.kTextColor),
                        Text("Xóa", style: TextStyle(color: AppConst.kTextColor)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
  }

  void openFindWay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialogCustom(
          notification: 'Chỉ đường',
          children2: Column(
            children: [
              TextFormField(
                controller: chat.originController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'Bắt đầu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(width: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Icon(Icons.arrow_downward_outlined),
              const SizedBox(height: 5),
              TextFormField(
                controller: chat.destinationController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'Điểm đến',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(width: 0.3),
                  ),
                ),
              ),
            ],
          ),
          onPress: () {
            final String findWay = 'Chỉ đường từ ${chat.originController.text} đến ${chat.destinationController.text}';
            chat.handleSubmitted(findWay);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
