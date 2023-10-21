import 'package:get/get.dart';
import 'package:tourly/views/favorite_page/favorite_page.dart';
import 'package:tourly/views/search_page/search_page.dart';
import 'package:tourly/views/setting_page/setting.dart';
import 'package:tourly/views/support_page/support_page.dart';

class HomePageController extends GetxController {
  Rx<int> selectedIndex = 0.obs; //New

  RxList<dynamic> pages = [
    SearchPage(),
    // const ChatPage(),
    FavoritePage(),
    SupportPage(),
    Setting(),
  ].obs;

  setChildrenPageIndex(index) => selectedIndex.value = index;
  chooseChildrenPage() => pages[selectedIndex.value];
}
