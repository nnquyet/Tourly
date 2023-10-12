import 'package:get/get.dart';
import 'package:tourly/views/like_page.dart';
import 'package:tourly/views/search_page/search_page.dart';
import 'package:tourly/views/support_page.dart';

import '../../views/setting_page/setting.dart';

class HomePageController extends GetxController {
  Rx<int> selectedIndex = 0.obs; //New

  RxList<dynamic> pages = [
    SearchPage(),
    // const ChatPage(),
    LikePage(),
    SupportPage(),
    Setting(),
  ].obs;

  setChildrenPageIndex(index) => selectedIndex.value = index;
  chooseChildrenPage() => pages[selectedIndex.value];
}
