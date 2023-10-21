import 'dart:async';

import 'package:get/get.dart';
import 'package:tourly/controllers/auth_controller/handle_user.dart';

class FavoritePageController extends GetxController {
  final size = Get.size.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    Future.delayed(const Duration(milliseconds: 0), () async {
      // await getDataFromApi();
      await HandleUser().getIdFavoritesFromFirestore();
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
  }
}
