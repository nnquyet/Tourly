import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tourly/views/account_page.dart';
import 'package:tourly/views/chat_page.dart';
import 'package:tourly/views/like_page.dart';
import 'package:tourly/views/search_page/search_page.dart';
import 'package:tourly/views/support_page.dart';

class HomePageController extends GetxController {
  Rx<int> selectedIndex = 0.obs; //New

  RxList<dynamic> pages = [
    SearchPage(),
    const ChatPage(),
    LikePage(),
    SupportPage(),
    const AccountPage(),
  ].obs;

  setChildrenPageIndex(index) => selectedIndex.value = index;
  chooseChildrenPage() => pages[selectedIndex.value];
}
