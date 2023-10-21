import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/controllers/auth_controller/handle_user.dart';
import 'package:tourly/models/address_model.dart';
import 'package:tourly/views/search_page/search_bar_page.dart';

class SearchPageController extends GetxController {
  //main controller
  final size = Get.size.obs;
  late Rx<TextEditingController> searchBarController;
  RxList<AddressModel> addressList = <AddressModel>[].obs;
  RxList<AddressModel> filterAddressList = <AddressModel>[].obs;
  Rx<bool> isVisibleFilterAddress = false.obs;
  Rx<bool> isShowIconClose = false.obs;
  Rx<FocusNode> searchFocusNode = FocusNode().obs;
  // Rx<FocusNode> searchBarFocusNode = FocusNode().obs;
  RxDouble xPosition = 0.0.obs;
  RxDouble yPosition = 0.0.obs;

  //option controller
  RxString selectedAddress = "".obs;
  RxString selectedEntertain = "".obs;
  RxString selectedCulture = "".obs;
  RxString selectedNature = "".obs;
  RxString selectedActivities = "".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    searchBarController = TextEditingController().obs;
    xPosition.value = size.value.width * 0.79;
    yPosition.value = size.value.height * 0.60;

    Future.delayed(const Duration(milliseconds: 0), () async {
      // await getDataFromApi();
      await HandleUser().getLocationsFromFirestore();
    });
    searchFocusNode.value.addListener(() {
      Get.to(SearchBarPage());
      filterAddressList.value = addressList;
      searchFocusNode.value.unfocus();
    });
    // addressList.add((AddressModel(activities: 'abc', address: 'abc', describe: 'abc', like: 1, name: 'abc')));
    // addressList.add((AddressModel(activities: 'abc', address: 'abc', describe: 'abc', like: 1, name: 'abc')));
  }

  @override
  void onClose() {
    // TODO: implement onClose
    searchBarController.value.dispose();
    searchFocusNode.value.dispose();
  }

  Container buildButtonOptions(String titleOptions, RxString options) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color(0xFFeaeaea),
      ),
      child: Row(
        children: [
          options.isEmpty
              ? Text(
                  titleOptions,
                  style: const TextStyle(
                    fontSize: AppConst.kSubFontSize,
                    color: AppConst.kTextColor,
                    fontFamily: "Roboto",
                  ),
                  textAlign: TextAlign.center,
                )
              : Text(
                  options.value,
                  style: const TextStyle(
                    fontSize: AppConst.kSubFontSize,
                    color: AppConst.kTextColor,
                    fontFamily: "Roboto",
                  ),
                  textAlign: TextAlign.center,
                ),
          options.isEmpty
              ? const Icon(Icons.keyboard_arrow_down_outlined, color: AppConst.kSubTextColor)
              : GestureDetector(
                  onTap: () {
                    options.value = "";
                    filterAddress();
                  },
                  child: const Icon(
                    Icons.close,
                    color: AppConst.kTextColor,
                    size: 20,
                  ),
                ),
        ],
      ),
    );
  }

  void searchAddress(String searchText) {
    final filteredName =
        addressList.where((address) => address.name.toLowerCase().contains(searchText.toLowerCase().trim())).toList();
    final filteredAddress = addressList
        .where((address) => address.address.toLowerCase().contains(searchText.toLowerCase().trim()))
        .toList();
    final filteredKeywords = addressList
        .where((address) => address.keywords.toLowerCase().contains(searchText.toLowerCase().trim()))
        .toList();

    filteredName.addAll(filteredAddress);
    filteredName.addAll(filteredKeywords);
    Set<AddressModel> filteredDuplicate = Set<AddressModel>.from(filteredName);
    filterAddressList.value = filteredDuplicate.toList();
  }

  void filterAddress() {
    filterAddressList.value = addressList;
    if (selectedAddress.isNotEmpty) {
      filterAddressList.value = filterAddressList
          .where((address) => address.address.toLowerCase().contains(selectedAddress.value.toLowerCase().trim()))
          .toList();
    }
    if (selectedEntertain.isNotEmpty) {
      filterAddressList.value = filterAddressList
          .where((address) => address.keywords.toLowerCase().contains(selectedEntertain.value.toLowerCase().trim()))
          .toList();
    }
    if (selectedCulture.isNotEmpty) {
      filterAddressList.value = filterAddressList
          .where((address) => address.keywords.toLowerCase().contains(selectedCulture.value.toLowerCase().trim()))
          .toList();
    }
    if (selectedNature.isNotEmpty) {
      filterAddressList.value = filterAddressList
          .where((address) => address.keywords.toLowerCase().contains(selectedNature.value.toLowerCase().trim()))
          .toList();
    }
    if (selectedActivities.isNotEmpty) {
      filterAddressList.value = filterAddressList
          .where((address) => address.keywords.toLowerCase().contains(selectedActivities.value.toLowerCase().trim()))
          .toList();
    }

    Set<AddressModel> filteredDuplicate = Set<AddressModel>.from(filterAddressList);
    filterAddressList.value = filteredDuplicate.toList();
  }
}
