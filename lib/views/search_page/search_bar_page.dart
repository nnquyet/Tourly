import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/controllers/resource.dart';
import 'package:tourly/common/widgets/address_card_detail.dart';
import 'package:tourly/common/widgets/text_field_container.dart';
import 'package:tourly/controllers/home_page_controller/search_page_controller.dart';
import 'package:tourly/common/widgets/address_card.dart';

class SearchBarPage extends StatelessWidget {
  SearchBarPage({super.key});

  final SearchPageController search = Get.find();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Obx(
      () {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: AppConst.kPrimaryLightColor,
            elevation: 3,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  // color: Colors.red,
                  child: Transform.translate(
                    offset: Offset(-5, 0),
                    child: GestureDetector(
                      onTap: () {
                        search.searchBarController.value.text = "";
                        search.searchAddress('');
                        search.filterAddressList.value = search.addressList;
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
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
                      autofocus: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppConst.kPrimaryColor),
                        suffixIcon: !search.isShowIconClose.value
                            ? InkWell(
                                onTap: () {},
                                child: const Icon(Icons.search_outlined, color: AppConst.kPrimaryColor),
                              )
                            : InkWell(
                                onTap: () {
                                  search.searchBarController.value.text = "";
                                  search.searchAddress('');
                                  search.isShowIconClose.value = false;
                                },
                                child: const Icon(Icons.close_outlined, color: AppConst.kPrimaryColor),
                              ),
                        hintText: "Nhập địa điểm, hoạt động, sở thích...",
                        hintStyle: const TextStyle(color: AppConst.kSubTextColor),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      onChanged: (value) {
                        search.searchAddress(value);
                        search.isShowIconClose.value = value.isNotEmpty;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ListView.builder(
              itemCount: search.filterAddressList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Get.to(() => AddressCardDetail(addressModel: search.filterAddressList[index]));
                  },
                  child: Row(
                    children: [
                      FutureBuilder<String>(
                        future: Resource().getImageUrl(Resource().convertToSlug(search.filterAddressList[index].name)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 60,
                              width: 60,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return const SizedBox(
                              height: 60,
                              width: 60,
                              child: Center(child: Text('Error loading image')),
                            );
                          }

                          return Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            height: 60,
                            width: 60,
                          );
                        },
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(search.filterAddressList[index].name),
                          subtitle: Text(search.filterAddressList[index].address),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
