import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:text_to_speech/text_to_speech.dart';
import 'package:tourly/common/api_services.dart';
import 'package:tourly/common/widgets/alert_dialog.dart';
import 'package:tourly/common/widgets/showToast.dart';
import 'package:tourly/controllers/auth_controller/data_user.dart';
import 'package:tourly/controllers/auth_controller/handle_user.dart';
import 'package:tourly/controllers/home_page_controller/setting_controller.dart';
import 'package:tourly/views/chat_page/chat_item.dart';
import 'package:video_player/video_player.dart';

class ChatController extends GetxController {
  final SettingController setting = Get.find();
  final box = GetStorage();
  final size = Get.size.obs;
  final TextEditingController textEditingController = TextEditingController();
  final scrollControllerListMess = ScrollController();
  final focusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;

  RxString position = ''.obs;
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxList<dynamic> messagesList = <dynamic>[].obs;
  RxBool switchType = true.obs;
  RxBool isLoading = false.obs;
  RxBool showQuestionsSuggest = false.obs;
  RxBool showImagesSuggest = false.obs;
  RxBool checkGenerateReply = false.obs;
  RxBool checkGenerateQuestion = false.obs;
  List<String> images = List.filled(4, '');
  List<String> suggestQuestion = List.filled(4, '');
  RxString translatedTextImage = ''.obs;
  RxBool display = true.obs;
  RxString questionScreenBot = ''.obs;
  final List<int> lengthMessage = List.filled(20, 0);
  RxInt indexCurrent = 0.obs;
  RxInt index = 0.obs;
  RxBool displaySuggestWhenScroll = true.obs;
  RxBool displayIconCompose = true.obs;
  RxList<String> resultUrls = <String>[].obs;
  RxList<String> resultDomains = <String>[].obs;
  RxString cityWeather = ''.obs;
  RxString time = ''.obs;
  RxString previousDate = ''.obs;
  RxString currentDate = ''.obs;
  RxDouble xPosition = 0.0.obs;
  RxDouble yPosition = 0.0.obs;

  // Select & Share
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController shareEmailController = TextEditingController();
  RxBool isChooseMany = false.obs;
  RxBool isChooseAll = false.obs;
  RxList<bool> selectedMessage = <bool>[].obs;

  // Video
  late VideoPlayerController videoPlayerController;
  RxInt currentVideoIndex = 1.obs;

  // Text to Speech
  final TextToSpeech textToSpeech = TextToSpeech();
  final audioPlayer = AudioPlayer();
  RxBool isListening = false.obs;
  RxBool checkPop = true.obs;
  RxString textSpeech = ''.obs;

  // Speech to Text
  late stt.SpeechToText speechToText;

  // Image to text
  // RxString imagePath = ''.obs;
  // RxString textFromImage = ''.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    xPosition.value = size.value.width * 0.79;
    yPosition.value = size.value.height * 0.68;

    time.value = DateFormat('EEEE, yyyy MMMM d, h:mm a').format(DateTime.now());

    speechToText = stt.SpeechToText();
    textToSpeech.setLanguage('en-US');
    if (Platform.isAndroid) {
      textToSpeech.setLanguage('en-US');
    } else {
      textToSpeech.setLanguage('vi-VN');
      textToSpeech.setRate(1.06);
    }

    Future.delayed(Duration.zero, () async {
      await initializeVideoPlayer();
    });
    scrollControllerListMess.addListener(() {
      double currentPosition = scrollControllerListMess.position.pixels;
      double minScrollExtent = scrollControllerListMess.position.minScrollExtent;
      double maxScrollExtent = scrollControllerListMess.position.maxScrollExtent;
      if (currentPosition == minScrollExtent && !displaySuggestWhenScroll.value) {
        // suggestTopic = true;
        showQuestionsSuggest.value = true;
        showImagesSuggest.value = true;
        display.value = true;
        displaySuggestWhenScroll.value = true;
      } else if (currentPosition != minScrollExtent && displaySuggestWhenScroll.value) {
        // suggestTopic = false;
        showQuestionsSuggest.value = false;
        showImagesSuggest.value = false;
        display.value = false;
        displaySuggestWhenScroll.value = false;
      }
      // lengthMessage[0] = messages[0].text.length;
      // for (int i = 1; i < messages.length; i++) {
      //   lengthMessage[i] = messages[i].text.length + lengthMessage[i - 1];
      // }
      //
      // int pos = (lengthMessage[19] / maxScrollExtent * currentPosition).floor();
      // for (int i = 0; i < messages.length; i++) {
      //   if (lengthMessage[i] > pos) {
      //     index.value = i;
      //     if (messages[index.value].time != messages[indexCurrent.value].time) {
      //       indexCurrent = index;
      //     }
      //     break;
      //   }
      // }
    });
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    Future.delayed(Duration.zero, () async {
      await waitData();
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    videoPlayerController.dispose();
    keyboardSubscription.cancel();
    focusNode.dispose();
  }

  Future<void> waitData() async {
    messages.value = await HandleUser().readChat();

    // prefs.getStringList('chat_channel') == null || prefs.getStringList('chat_channel')!.isEmpty
    //     ? chatChannel = ['ChatGPT'].toSet()
    //     : chatChannel = prefs.getStringList('chat_channel')!.toSet();
    // print('getStringList: ${chatChannel.toString()}');
    // mapKeywordsFromDB = await _handle.readKeywords();

    // messages.clear();
    // messagesList.clear();
    // selectedMessage.clear();
    // messages.addAll(messages2);
    addTime();
    selectedMessage.value = List.generate(messagesList.length, (index) => false);
  }

  Future<void> initializeVideoPlayer() async {
    videoPlayerController = VideoPlayerController.asset('assets/images/robot_girl_${currentVideoIndex.value}.mp4')
      ..initialize().then((_) {});
    videoPlayerController.play();
    videoPlayerController.setLooping(true);
  }

  void switchVideo() async {
    videoPlayerController.pause();
    currentVideoIndex.value = currentVideoIndex.value == 1 ? 2 : 1;
    final newController = VideoPlayerController.asset('assets/images/robot_girl_${currentVideoIndex.value}.mp4');
    await newController.initialize();
    videoPlayerController.dispose();
    videoPlayerController = newController;
    if (messagesList.isNotEmpty && messagesList[0] is ChatMessage) {
      messagesList.first.isNewMessage = false;
    }

    videoPlayerController.play();
    videoPlayerController.setLooping(true);
  }

  void addTime() {
    for (int i = messages.length - 1; i >= 0; i--) {
      ChatMessage message = messages[i];
      currentDate.value = message.time;

      if (previousDate.value == '' || currentDate.value.split(',')[1] != previousDate.value.split(',')[1]) {
        // Thêm ngày vào đầu tin nhắn đầu tiên của ngày đó
        DateTime date = DateFormat('EEEE, yyyy MMMM d, h:mm a').parse(currentDate.value);
        String day = DateFormat('EEEE, MMMM d').format(date);
        messagesList.insert(0, day);
      }

      // Thêm tin nhắn vào danh sách đã định dạng
      messagesList.insert(0, message);

      previousDate.value = currentDate.value;
    }
    print(messagesList.length);
  }

  Future<void> chooseImage() async {
    PermissionStatus permissionStatus = PermissionStatus.denied;
    if (Platform.isIOS) {
      permissionStatus = await Permission.photos.request();
    } else if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      permissionStatus =
          deviceInfo.version.sdkInt < 33 ? await Permission.storage.request() : await Permission.photos.request();
    } else {
      permissionStatus = await Permission.photos.request();
    }

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        // Xử lý ảnh đã chọn tại đây
        // imagePath.value = pickedImage.path;
        // _imageFile = File(pickedImage.path);
        await uploadImage(pickedImage.path);
        // upload(File(pickedImage.path));
      }
    } else if (permissionStatus.isPermanentlyDenied || permissionStatus.isLimited) {
      // Quyền truy cập vào thư viện ảnh bị từ chối vĩnh viễn
      // Hiển thị thông báo và hướng dẫn người dùng mở cài đặt ứng dụng

      const ShowToast(text: 'Hãy cấp quyền mở thư viện ảnh!').show();

      await openAppSettings();
    }
  }

  Future<void> openCamera() async {
    PermissionStatus permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        // Xử lý ảnh đã chọn tại đây
        // _imageFile = File(pickedFile.path);
        await uploadImage(pickedImage.path);
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      // Quyền truy cập vào may ảnh bị từ chối vĩnh viễn
      // Hiển thị thông báo và hướng dẫn người dùng mở cài đặt ứng dụng
      const ShowToast(text: 'Hãy cấp quyền mở Camera!').show();
      await openAppSettings();
    }
  }

  Future<void> handleSubmitted(String text) async {
    textEditingController.clear();
    resultUrls.clear();
    resultDomains.clear();
    // listKeywords.clear();
    images.fillRange(0, 3, '');
    String result = '';
    translatedTextImage.value = '';
    checkGenerateQuestion.value = false;
    showImagesSuggest.value = false;
    String replyText = '';
    // String keywordForImage = '';
    String weatherCurrent = '';
    String weather5Days = '';

    if (previousDate.value == '' || time.split(',')[1] != previousDate.split(',')[1]) {
      // Thêm ngày vào đầu tin nhắn đầu tiên của ngày đó
      DateTime date = DateFormat('EEEE, yyyy MMMM d, h:mm a').parse(time.value);
      String day = DateFormat('EEEE, MMMM d').format(date);
      messagesList.insert(0, day);
      selectedMessage.insert(0, false);
      previousDate = time;
    }

    for (var mess in messagesList) {
      if (mess is ChatMessage) {
        mess.isDisplayTime = false;
      }
    }

    if (text.toLowerCase().contains('thời tiết tại')) {
      cityWeather.value = text.toLowerCase().split('tại')[1].trim();
      weatherCurrent = await ApiChatBotServices.fetchWeatherData(cityWeather.value);
      if (weatherCurrent != 'Không tìm thấy địa điểm của bạn') {
        weather5Days = await ApiChatBotServices.fetchWeatherForecast(cityWeather.value);
      }
    } else if (text.toLowerCase().contains('thời tiết')) {
      position.value = (await getGeoLocationPosition())!;
      print('positiondebug: $position');
      print('city: $cityWeather');
      weatherCurrent = await ApiChatBotServices.fetchWeatherData(cityWeather.value);
      if (weatherCurrent != 'Không tìm thấy địa điểm của bạn') {
        weather5Days = await ApiChatBotServices.fetchWeatherForecast(cityWeather.value);
      }
      if (position.value == 'Location services are disabled.') {
        replyText =
            'Vui lòng bật vị trí để biết thông tin thời tiết tại địa điểm này. Nếu bạn muốn xem thời tiết tại vị trí cụ thể hãy nhập theo ví dụ: "Thời tiết tại Hà Nội"';
      } else if (position.value == 'Location permissions are denied' ||
          position.value == 'Location permissions are permanently denied, we cannot request permissions.') {
        replyText =
            'Vui lòng cấp quyền truy cập vị trí để biết thông tin chi tiết tại địa điểm này. Nếu bạn muốn xem thời tiết tại vị trí cụ thể hãy nhập theo ví dụ: "Thời tiết tại Hà Nội"';
      } else {
        text = 'thời tiết $position';
      }
    }

    ChatMessage chatMessage = ChatMessage(
      text: text,
      isUser: true,
      isNewMessage: false,
      isDisplayTime: false,
      time: time.value,
    );

    if (messagesList.isNotEmpty && messagesList[0] is ChatMessage) {
      messagesList.first.isNewMessage = false;
    }

    messagesList.insert(0, chatMessage);
    selectedMessage.insert(0, false);
    messages.insert(0, chatMessage);
    questionScreenBot.value = text;

    if (!replyText.contains('Vui lòng')) {
      if (chatMessage.text.toLowerCase().contains('thời tiết tại')) {
        replyText = "Hãy xem thêm thông tin thời tiết ở bên dưới\n$weatherCurrent\n$weather5Days";
      } else if (text.toLowerCase().contains('thời tiết')) {
        replyText =
            'Hãy xem thông tin thời tiết tại $position ở bên dưới. Nếu bạn muốn xem thời tiết tại vị trí khác hãy nhập theo ví dụ: "Thời tiết tại Hà Nội"\n$weatherCurrent\n$weather5Days';
      } else {
        if (setting.selectedChatChannels.value == 0) {
          replyText = await ApiChatBotServices().sendMessage(messages.map((message) => message.text).toList());
        }
      }
    }

    if (text.contains('Chỉ đường từ')) {
      replyText = await ApiChatBotServices.getDirections(originController.text, destinationController.text);
      originController.clear();
      destinationController.clear();
    }

    // replyText = msg.trim().replaceAll('\n', '').isEmpty ? HandleUser().handleUserInput(text) : msg.trim();
    //
    // if (replyText == 'Xin lỗi, tôi không hiểu câu hỏi của bạn. Hãy thử lại với câu hỏi khác.') {
    //   replyText = await ApiChatBotServices().claudeAI(text);
    // }

    if (replyText == '') {
      replyText = 'Api key của bạn không hợp lệ, vui lòng kiểm tra lại trong Setting';
    }

    ChatMessage reply = ChatMessage(
      text: replyText,
      isUser: false,
      isNewMessage: true,
      isDisplayTime: false,
      time: time.value,
    );

    await HandleUser().addChat(chatMessage.text, reply.text, time.value);

    playAudio(reply);

    print('rep: ${reply.text}');

    //Get translate from API
    translatedTextImage.value = await ApiChatBotServices().translate(chatMessage.text, reply.text);

    if (translatedTextImage.value == '') {
      translatedTextImage.value = text;
    }
    print('translatedTextImage: $translatedTextImage');

    if (chatMessage.text.toLowerCase().contains('thời tiết')) {
      translatedTextImage.value = chatMessage.text;
    }

    // Nhờ bot viết câu hỏi gợi ý
    result = await ApiChatBotServices().buildQuestions(reply.text);
    print('question: $result');
    handleQuestionReturn(result);

    //Get image from API
    if (setting.generateImage.value) {
      if (setting.imageSource.value == 'Google') {
        images = await ApiChatBotServices.getImagesFromGG(chatMessage.text);
        showImagesSuggest.value = true;
      } else {
        images = await ApiChatBotServices().generateImage(translatedTextImage.value);
        showImagesSuggest.value = true;
      }
    }

    if (replyText ==
            'Api key của bạn không hợp lệ, vui lòng kiểm tra lại trong Setting/bot. Hoặc xem thêm ở bên dưới...' ||
        translatedTextImage.value == '') {
      showQuestionsSuggest.value = false;
    }

    await searchInBrowser(translatedTextImage.value);
  }

  Future<void> searchInBrowser(String keyword) async {
    final url = 'https://www.google.com/search?q=${Uri.encodeQueryComponent(keyword)}';
    final response = await http.get(Uri.parse(url));
    final html = response.body;

    int count = 0;
    int startIndex = html.indexOf('href="/url?q=') + 13;
    while (startIndex != -1 && count < 3) {
      final endIndex = html.indexOf('&', startIndex);
      final firstResultUrl = Uri.decodeQueryComponent(html.substring(startIndex, endIndex));
      resultUrls.add(firstResultUrl);
      startIndex = html.indexOf('href="/url?q=', endIndex) + 13;
      count++;
    }

    for (String url in resultUrls) {
      Uri uri = Uri.parse(url);
      String domain = uri.host;
      resultDomains.add(domain);
      print('url: $url}');
    }
  }

  Future<void> playAudio(ChatMessage reply) async {
    try {
      if (setting.generateVoice.value.toString() == 'false') {
        messagesList.insert(0, reply);
        selectedMessage.insert(0, false);
        messages.insert(0, reply);
        showQuestionsSuggest.value = true;
        Future.delayed(Duration(milliseconds: reply.text.length * 30), () {
          if (messagesList.isNotEmpty && messagesList[0] is ChatMessage) {
            messagesList.first.isNewMessage = false;
            checkGenerateReply.value = true;
          }
        });
      } else if (setting.selectedVoice.value == 'Google') {
        messagesList.insert(0, reply);
        selectedMessage.insert(0, false);
        messages.insert(0, reply);
        showQuestionsSuggest.value = true;
        switchVideo();
        checkGenerateReply.value = false;
        textToSpeech.speak(reply.text);
        Future.delayed(Duration(milliseconds: reply.text.length * 60), () {
          if (currentVideoIndex.value == 2) {
            switchVideo();
            checkGenerateReply.value = true;
          }
        });
      } else {
        String audioUrl = await ApiChatBotServices().getAudioUrl(reply.text);
        await audioPlayer.play(UrlSource(audioUrl));
        messagesList.insert(0, reply);
        selectedMessage.insert(0, false);
        messages.insert(0, reply);
        showQuestionsSuggest.value = true;
        switchVideo();

        // 3 cho AudioPlayerState.completed.
        audioPlayer.onPlayerStateChanged.listen((playerState) {
          if (playerState.index == 3 && currentVideoIndex.value == 2) {
            switchVideo();
            checkGenerateReply.value = true;
          }
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String handleString(String input) {
    int colonIndex = input.indexOf(':');
    if (colonIndex != -1) {
      input = input.replaceAll(RegExp(r'[()\[\]]'), '');
      return input.substring(colonIndex + 1).trim();
    }
    return '';
  }

  void handleQuestionReturn(String result) {
    result = result.replaceAll(RegExp(r'\d+\.'), '');
    result = result.trim();
    var resultSplit = result.split('\n');
    suggestQuestion = resultSplit.sublist(max(0, resultSplit.length - 4));
    if (suggestQuestion.length < 4) {
      for (int i = suggestQuestion.length; i < 4; ++i) {
        suggestQuestion.add("This is a suggest question");
      }
    }

    if (!suggestQuestion.contains('This is a suggest question')) checkGenerateQuestion.value = true;
  }

  Future<String?> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // await Geolocator.openLocationSettings();
      return 'Location services are disabled.';
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return 'Location permissions are denied';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return 'Location permissions are permanently denied, we cannot request permissions.';
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      cityWeather.value = placemarks[0].administrativeArea!;
      return placemarks[0].subAdministrativeArea;
    } catch (err) {
      // print('');
    }
    return null;
  }

  Future<void> createPDF(BuildContext context) async {
    // final pdf = pw.Document();
    // final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    // final ttf = pw.Font.ttf(font);
    // bool success = false;
    //
    // List<pw.Widget> widgets = [];
    // final messageLength = messages.length;
    // final conversationTextStyle = pw.TextStyle(
    //   font: ttf,
    //   fontWeight: pw.FontWeight.bold,
    //   color: const PdfColor(1, 1, 1),
    // );
    //
    // for (int i = messageLength - 1; i >= 0; --i) {
    //   final sender = (i % 2 == 0) ? 'GLEAN' : 'USER';
    //
    //   widgets.add(
    //     pw.Container(
    //       alignment: pw.Alignment.center,
    //       padding: const pw.EdgeInsets.symmetric(vertical: 10),
    //       color: (i % 2 == 0) ? const PdfColor(0.2, 0.21, 0.25) : const PdfColor(0.27, 0.27, 0.33),
    //       child: pw.Row(
    //         crossAxisAlignment: pw.CrossAxisAlignment.start,
    //         children: [
    //           pw.SizedBox(width: 50, child: pw.Text('$sender:', style: conversationTextStyle)),
    //           pw.SizedBox(width: 10),
    //           pw.Flexible(child: pw.Text(messages[i].text, style: conversationTextStyle)),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    //
    // try {
    //   pdf.addPage(
    //     pw.MultiPage(
    //       pageFormat: PdfPageFormat.a4,
    //       build: (context) => widgets, //here goes the widgets list
    //     ),
    //   );
    //
    //   final directory = await getApplicationSupportDirectory();
    //   final path = directory.path;
    //   final file = File('$path/$titleConversation.pdf');
    //
    //   await file.writeAsBytes(await pdf.save());
    //   OpenFile.open('$path/$titleConversation.pdf');
    //   success = true;
    // } catch (e) {
    //   // print('');
    // }
    //
    // if (!success) {
    //   const ShowToast(text: 'Không thể xuất file do có câu hỏi hoặc câu trả lời quá dài!').show();
    // }
  }

  void shareMessagesWithEmail(BuildContext context, List<String> listMessagesShare) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialogCustom(
          notification: "Chia sẻ tới",
          children2: TextFormField(
            controller: shareEmailController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              hintText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(width: 0.3),
              ),
            ),
          ),
          onPress: () async {
            // Navigator.pop(context);
            //
            // String date = DateFormat('dd-MM-yyyy  hh:mm:ss a').format(DateTime.now());
            // setState(() {
            //   isLoading.value = true;
            // });
            //
            // late UserCustom userCustomShare;
            // final userRef = FirebaseFirestore.instance.collection('users').doc(shareEmailComtroller.text);
            // final documentSnapshot = await userRef.get();
            // if (documentSnapshot.exists) {
            //   print('Tài liệu đã tồn tại!');
            //   final data = documentSnapshot.data();
            //   final dataConvert = data as Map;
            //   userCustomShare = UserCustom.fromJson(dataConvert);
            //   final lengthListMessageShare = listMessagesShare.length;
            //   // print('listmessage: ${listMessagesShare.length}');
            //   for (int i = 0; i < lengthListMessageShare; i = i + 2) {
            //     // print("listmessage: ${listMessagesShare[i]} ${listMessagesShare[i + 1]}");
            //     await Handle().addChat(userCustomShare.id, '${date}?Shared by ${MyData.userCustom!.name}',
            //         "Shared by ${MyData.userCustom!.name}", listMessagesShare[i], listMessagesShare[i + 1], time);
            //   }
            // } else {
            //   print('Tài liệu không tồn tại.');
            // }
            // setState(() {
            //   isChooseMany.value = false;
            //   isLoading.value = false;
            // });
          },
        );
      },
    );
  }

  Future<void> deleteMessage(BuildContext context, List<ChatMessage> listMessageAfterDelete) async {
    // DocumentReference documentReference =
    //     FirebaseFirestore.instance.collection(MyData.userCustom?.id).doc('${widget.section}?$titleConversation');
    // documentReference.delete();
    //
    // setState(() {
    //   isLoading.value = true;
    // });
    // final lengthListMessageShare = listMessageAfterDelete.length;
    // for (int i = 0; i < lengthListMessageShare; i = i + 2) {
    //   print('listmessageafter: ${listMessageAfterDelete[i].text}\n${listMessageAfterDelete[i + 1].text}');
    //   await Handle().addChat(widget.userCustom.id, '${widget.section}?$titleConversation', titleConversation,
    //       listMessageAfterDelete[i].text, listMessageAfterDelete[i + 1].text, listMessageAfterDelete[i].time);
    // }
    // setState(() {
    //   isLoading.value = false;
    //   isChooseMany.value = false;
    //   checkSetState = true;
    // });
  }

  Future<void> uploadImage(String pickedImage) async {
    resultUrls.clear();
    resultDomains.clear();
    images.fillRange(0, 3, '');
    translatedTextImage.value = '';
    checkGenerateQuestion.value = false;
    showImagesSuggest.value = false;

    if (messagesList.isNotEmpty && messagesList[0] is ChatMessage) {
      messagesList.first.isNewMessage = false;
    }
    ChatMessage question = ChatMessage(
      text: 'Bạn hãy kiểm tra mắt giúp tôi!',
      isUser: true,
      isNewMessage: false,
      isDisplayTime: false,
      time: time.value,
    );
    messagesList.insert(0, question);
    messagesList.insert(0, pickedImage);

    try {
      // String apiUrl = 'http://117.6.135.148:8000';
      String apiUrl = 'http://117.6.135.148:8703';
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      File rotatedImage = await FlutterExifRotation.rotateImage(path: pickedImage);
      var file = await http.MultipartFile.fromPath('uploaded_file', rotatedImage.path);
      // var file = await http.MultipartFile.fromPath('uploaded_file', pickedImage);

      request.files.add(file);

      var response = await request.send();

      if (response.statusCode == 200) {
        // Xử lý kết quả trả về từ API (nếu cần).
        var responseData = await response.stream.toBytes();
        var responseString = utf8.decode(responseData);
        String textFromImage = json.decode(responseString)['message'];
        print(textFromImage);

        // Thực hiện các thao tác tiếp theo dựa trên kết quả từ API.
        textFromImage += '\n\nBạn hãy mô tả kỹ hơn để chúng tôi tư vấn!';
        ChatMessage replyModel = ChatMessage(
          text: textFromImage,
          isUser: false,
          isNewMessage: true,
          isDisplayTime: false,
          time: time.value,
        );
        messagesList.insert(0, replyModel);
        Future.delayed(Duration(milliseconds: textFromImage.length * 60), () {
          if (messagesList.isNotEmpty && messagesList[0] is ChatMessage) {
            messagesList.first.isNewMessage = false;
          }
        });

        File imageFile = File(pickedImage); //convert Path to File
        final _firebaseStorage = FirebaseStorage.instance;
        var snapshot = await _firebaseStorage
            .ref()
            .child('chatImages/${DataUser.userModel.value.id}_${basename(imageFile.path)}')
            .putFile(imageFile);
        var downloadUrl = await snapshot.ref.getDownloadURL();

        await HandleUser().addChat('${question.text}\n$downloadUrl', replyModel.text, time.value);
      } else {
        // Xử lý trường hợp không thành công.
      }
    } catch (e) {
      // Xử lý lỗi nếu có.
      print('Error: $e');
    }
  }

  upload(File imageFile) async {
    // open a bytestream
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("http://117.6.135.148:8000");

    // create multipart request
    var request = http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = http.MultipartFile('uploaded_file', stream, length, filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }
  //
  // Future<void> download(String url) async {
  //   final response = await http.get(Uri.parse(url));
  //
  //   // Get the image name
  //   final imageName = path.basename(url);
  //   // Get the document directory path
  //   final appDir = await getApplicationDocumentsDirectory();
  //
  //   // This is the saved image path
  //   // You can use it to display the saved image later
  //   final localPath = path.join(appDir.path, imageName);
  //
  //   // Downloading
  //   final imageFile = File(localPath);
  //   await imageFile.writeAsBytes(response.bodyBytes);
  // }
}
