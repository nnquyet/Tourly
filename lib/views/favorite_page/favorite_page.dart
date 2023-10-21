import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/controllers/auth_controller/data_user.dart';
import 'package:tourly/controllers/auth_controller/handle_user.dart';
import 'package:tourly/controllers/home_page_controller/favorite_page_controller.dart';
import 'package:tourly/views/cards/address_card_detail.dart';
import 'package:tourly/views/cards/address_card.dart';

class FavoritePage extends StatelessWidget {
  FavoritePage({super.key});

  FavoritePageController favorite = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppConst.kPrimaryLightColor,
              elevation: 1,
              automaticallyImplyLeading: false,
              title: const Text('Danh sách yêu thích',
                  style: TextStyle(color: AppConst.kTextColor, fontSize: 18, fontWeight: FontWeight.w600)),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: favorite.size.value.width * 0.06),
                  child: ListView.builder(
                    itemCount: DataUser.favoritesList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: InkWell(
                            onTap: () {
                              HandleUser().increaseViews(DataUser.favoritesList[index]);
                              Get.to(() => AddressCardDetail(addressModel: DataUser.favoritesList[index]));
                            },
                            child: AddressCard(DataUser.favoritesList[index])),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
