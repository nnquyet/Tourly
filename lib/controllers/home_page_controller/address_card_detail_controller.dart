import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tourly/controllers/auth_controller/handle_user.dart';
import 'package:tourly/models/comment_model.dart';

class AddressCardDetailController extends GetxController {
  final box = GetStorage();
  final size = Get.size.obs;

  RxBool like = false.obs;
  RxString idAddress = ''.obs;

  RxList<CommentModel> commentList = <CommentModel>[].obs;
  late Rx<TextEditingController> commentController;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    commentController = TextEditingController().obs;
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    print('length: ${idAddress.value}');

    Future.delayed(Duration.zero, () async {
      commentList.value = await HandleUser().readComment(idAddress.value);
      print('length: ${commentList.length}');
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    commentController.value.dispose();
  }
}
