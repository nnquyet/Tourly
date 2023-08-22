import 'dart:convert';

import 'package:get/get.dart';
import 'package:tourly/models/address_model.dart';

class ManageController extends GetxController {
  RxList listPostByUsername = <AddressModel>[].obs;

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
