import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/views/cards/address_card_detail.dart';
import 'package:tourly/controllers/home_page_controller/search_page_controller.dart';
import 'package:tourly/views/cards/address_card.dart';
import 'package:tourly/views/search_page/search_bar_page.dart';

import '../chat_page/chat_screen.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final SearchPageController search = Get.find();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Obx(
      () {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 110,
              backgroundColor: AppConst.kPrimaryLightColor,
              elevation: 1,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25), // Điều chỉnh độ cong của border tại đây
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Màu và độ trong suốt của bóng
                          spreadRadius: 1, // Độ rộng của bóng
                          blurRadius: 5, // Độ mờ của bóng
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: search.searchBarController.value,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(decoration: TextDecoration.none, color: AppConst.kTextColor),
                      focusNode: search.searchFocusNode.value,
                      autofocus: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppConst.kTextColor),
                        suffixIcon: InkWell(
                          onTap: () {
                            Get.to(SearchBarPage());
                          },
                          child: const Icon(Icons.search_outlined, color: AppConst.kTextColor),
                        ),
                        hintText: "Nhập địa điểm, hoạt động, sở thích...",
                        hintStyle: const TextStyle(color: AppConst.kSubTextColor),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      onChanged: (value) {
                        search.isShowIconClose.value = value.isNotEmpty;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          PopupMenuButton<String>(
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(value: 'Hà Nội', child: Text('Hà Nội')),
                                const PopupMenuItem(value: 'Hồ Chí Minh', child: Text('Hồ Chí Minh')),
                                const PopupMenuItem(value: 'Đà Nẵng', child: Text('Đà Nẵng')),
                              ];
                            },
                            constraints: BoxConstraints(maxWidth: 145),
                            offset: Offset(0, 32),
                            onSelected: (value) {
                              search.selectedAddress.value = value;
                              search.filterAddress();
                            },
                            child: search.buildButtonOptions("Địa điểm", search.selectedAddress),
                          ),
                          SizedBox(width: size.width * 0.02),
                          PopupMenuButton<String>(
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(value: 'Công viên', child: Text('Công viên')),
                                const PopupMenuItem(value: 'Sở thú', child: Text('Sở thú')),
                                const PopupMenuItem(value: 'Khu vui chơi', child: Text('Khu vui chơi')),
                                const PopupMenuItem(value: 'Dã ngoại', child: Text('Dã ngoại')),
                                const PopupMenuItem(value: 'Khu nghỉ dưỡng', child: Text('Khu nghỉ dưỡng')),
                                const PopupMenuItem(value: 'Âm nhạc', child: Text('Âm nhạc')),
                                const PopupMenuItem(value: 'Ẩm thực', child: Text('Ẩm thực')),
                                const PopupMenuItem(value: 'Mua sắm', child: Text('Mua sắm')),
                                const PopupMenuItem(value: 'Triển lãm', child: Text('Triển lãm')),
                              ];
                            },
                            constraints: BoxConstraints(maxWidth: 145),
                            offset: Offset(0, 32),
                            onSelected: (value) {
                              search.selectedEntertain.value = value;
                              search.filterAddress();
                            },
                            child: search.buildButtonOptions("Giải trí", search.selectedEntertain),
                          ),
                          SizedBox(width: size.width * 0.02),
                          PopupMenuButton<String>(
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(value: 'Di tích', child: Text('Di tích')),
                                const PopupMenuItem(value: 'Bảo tàng', child: Text('Bảo tàng')),
                                const PopupMenuItem(value: 'Đền chùa', child: Text('Đền chùa')),
                                const PopupMenuItem(value: 'Nhà thờ', child: Text('Nhà thờ')),
                                const PopupMenuItem(value: 'Truyền thống', child: Text('Truyền thống')),
                              ];
                            },
                            constraints: BoxConstraints(maxWidth: 130),
                            offset: Offset(0, 32),
                            onSelected: (value) {
                              search.selectedCulture.value = value;
                              search.filterAddress();
                            },
                            child: search.buildButtonOptions("Văn hoá", search.selectedCulture),
                          ),
                          SizedBox(width: size.width * 0.02),
                          PopupMenuButton<String>(
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(value: 'Cảnh đẹp', child: Text('Cảnh đẹp')),
                                const PopupMenuItem(value: 'Núi', child: Text('Núi')),
                                const PopupMenuItem(value: 'Biển', child: Text('Biển')),
                                const PopupMenuItem(value: 'Hồ', child: Text('Hồ')),
                                const PopupMenuItem(value: 'Thác', child: Text('Thác')),
                                const PopupMenuItem(value: 'Hang động', child: Text('Hang động')),
                                const PopupMenuItem(value: 'Đồng cỏ', child: Text('Đồng cỏ')),
                              ];
                            },
                            constraints: BoxConstraints(maxWidth: 120),
                            offset: Offset(0, 32),
                            onSelected: (value) {
                              search.selectedNature.value = value;
                              search.filterAddress();
                            },
                            child: search.buildButtonOptions("Thiên nhiên", search.selectedNature),
                          ),
                          SizedBox(width: size.width * 0.02),
                          PopupMenuButton<String>(
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(value: 'Leo núi', child: Text('Leo núi')),
                                const PopupMenuItem(value: 'Bơi', child: Text('Bơi')),
                                const PopupMenuItem(value: 'Đi phượt', child: Text('Đi phượt')),
                                const PopupMenuItem(value: 'Thăm quan', child: Text('Thăm quan')),
                                const PopupMenuItem(value: 'Đi bộ', child: Text('Đi bộ')),
                              ];
                            },
                            constraints: BoxConstraints(maxWidth: 125),
                            offset: Offset(0, 32),
                            onSelected: (value) {
                              search.selectedActivities.value = value;
                              search.filterAddress();
                            },
                            child: search.buildButtonOptions("Hoạt động", search.selectedActivities),
                          ),
                          SizedBox(width: size.width * 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(search.size.value.width * 0.06, search.size.value.width * 0.06,
                      search.size.value.width * 0.06, 0),
                  child: ListView.builder(
                    itemCount: search.filterAddressList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: InkWell(
                            onTap: () {
                              Get.to(() => AddressCardDetail(addressModel: search.filterAddressList[index]));
                            },
                            child: AddressCard(search.filterAddressList[index])),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: search.xPosition.value,
                  top: search.yPosition.value,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => Chat());
                    },
                    onPanUpdate: (details) {
                      search.xPosition.value += details.delta.dx;
                      search.yPosition.value += details.delta.dy;
                    },
                    child: Image.asset(
                      'assets/images/bot.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
