import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AddressCardDetailController extends GetxController {
  final box = GetStorage();
  final size = Get.size.obs;

  RxBool like = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
