import 'package:get/instance_manager.dart';
import 'package:tourly/controllers/home_page_controller/home_page_controller.dart';
import 'package:tourly/controllers/home_page_controller/search_page_controller.dart';
import 'package:tourly/controllers/home_page_controller/setting_controller.dart';

class AllBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => HomePageController());
    Get.lazyPut(() => SearchPageController());
    Get.lazyPut(() => SettingController());
  }
}
