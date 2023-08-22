import 'package:get/instance_manager.dart';
import 'package:tourly/common/controllers/validation_controller.dart';
import 'package:tourly/controllers/auth_controller/login_controller.dart';
import 'package:tourly/controllers/auth_controller/sign_up_controller.dart';
import 'package:tourly/controllers/home_page_controller/home_page_controller.dart';
import 'package:tourly/controllers/home_page_controller/manage_page_controller.dart';
import 'package:tourly/controllers/home_page_controller/search_page_controller.dart';

class AllBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => HomePageController());
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => SignupController());
    Get.lazyPut(() => ValidationController());
    Get.lazyPut(() => SearchPageController());
    Get.lazyPut(() => ManageController());
  }
}
