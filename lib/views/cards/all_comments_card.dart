import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/controllers/resource.dart';
import 'package:tourly/common/widgets/carousel_slider_comment_custom.dart';
import 'package:tourly/common/widgets/carousel_slider_image_custom.dart';
import 'package:tourly/controllers/auth_controller/data_user.dart';
import 'package:tourly/controllers/auth_controller/handle_user.dart';
import 'package:tourly/controllers/home_page_controller/address_card_detail_controller.dart';
import 'package:tourly/models/address_model.dart';
import 'package:tourly/models/comment_model.dart';

class AllCommentsCard extends StatelessWidget {
  const AllCommentsCard({super.key, required this.addressModel});

  final AddressModel addressModel;

  @override
  Widget build(BuildContext context) {
    final addressDetail = Get.put(AddressCardDetailController());
    addressDetail.idAddress.value = addressModel.id;

    return Obx(() {
      addressDetail.like.value = DataUser.idFavoritesList.contains(addressModel.id);
      return Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addressModel.urlList!.length == 1
                      ? FutureBuilder<List<String>>(
                          future: getImageUrlList(Resource().convertToSlug(addressModel.name)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox(
                                height: addressDetail.size.value.width * 0.7,
                                width: double.infinity,
                                child: const CupertinoActivityIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return SizedBox(
                                height: addressDetail.size.value.width * 0.7,
                                width: double.infinity,
                                child: const CupertinoActivityIndicator(),
                              );
                            }
                            addressModel.urlList = snapshot.data!;
                            return CarouselSliderImageCustom(
                              urlList: snapshot.data!,
                            );
                          },
                        )
                      : CarouselSliderImageCustom(
                          urlList: addressModel.urlList!,
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          addressModel.name,
                          style: const TextStyle(fontSize: AppConst.kFontSize * 1.6, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          addressModel.keywords,
                          style: const TextStyle(fontSize: AppConst.kFontSize, color: AppConst.kSubTextColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Divider(
                            thickness: 1,
                            color: Colors.black.withOpacity(0.15),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite_border,
                                  size: AppConst.kFontSize * 1.2,
                                  color: AppConst.kSubTextColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${addressModel.likes} lượt thích ',
                                  style: const TextStyle(
                                    fontSize: AppConst.kFontSize,
                                    color: AppConst.kSubTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: AppConst.kFontSize * 1.2,
                                  color: AppConst.kSubTextColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${addressModel.views} lượt xem ',
                                  style: const TextStyle(
                                    fontSize: AppConst.kFontSize,
                                    color: AppConst.kSubTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.comment_outlined,
                                  size: AppConst.kFontSize * 1.2,
                                  color: AppConst.kSubTextColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${addressDetail.commentList.length} bình luận',
                                  style: const TextStyle(
                                    decorationThickness: 2,
                                    fontSize: AppConst.kFontSize,
                                    color: AppConst.kSubTextColor,
                                  ),
                                ),
                              ],
                            ),
                            // Container(
                            //   decoration: const BoxDecoration(
                            //       border: Border(
                            //           bottom: BorderSide(
                            //     color: Colors.black,
                            //     width: 1, // Underline thickness
                            //   ))),
                            //   child: const Text(
                            //     '1 Bình luận',
                            //     style: TextStyle(
                            //       // decoration: TextDecoration.underline,
                            //       fontWeight: FontWeight.w600,
                            //       decorationThickness: 2,
                            //       fontSize: 15,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Divider(
                            thickness: 1,
                            color: Colors.black.withOpacity(0.15),
                          ),
                        ),
                        const Text(
                          'Nơi này có những gì cho bạn',
                          style: TextStyle(
                            color: AppConst.kTextColor,
                            fontSize: AppConst.kFontSize * 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          addressModel.describe.replaceAll('  ', '\n\n'),
                          style: const TextStyle(
                            fontSize: AppConst.kFontSize,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Divider(
                            thickness: 1,
                            color: Colors.black.withOpacity(0.15),
                          ),
                        ),
                        const Text(
                          'Nơi bạn sẽ đến',
                          style: TextStyle(
                              color: AppConst.kTextColor,
                              fontSize: AppConst.kFontSize * 1.4,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: AppConst.kFontSize * 1.2,
                              color: AppConst.kSubTextColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                addressModel.address,
                                style: const TextStyle(fontSize: AppConst.kFontSize, color: AppConst.kSubTextColor),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Divider(
                            thickness: 1,
                            color: Colors.black.withOpacity(0.15),
                          ),
                        ),
                        const Text(
                          'Bình luận',
                          style: TextStyle(
                              decorationThickness: 2,
                              fontSize: AppConst.kFontSize * 1.4,
                              color: AppConst.kTextColor,
                              fontWeight: FontWeight.w600),
                        ),
                        CarouselSliderCommentCustom(commentList: addressDetail.commentList),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppConst.kTextColor)),
                            child: Center(
                              child: Text(
                                'Hiển thị tất cả ${addressDetail.commentList.length} bình luận',
                                style: const TextStyle(
                                  decorationThickness: 2,
                                  fontSize: AppConst.kFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppConst.kTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppConst.kBotChatColor,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: TextFormField(
                                  // focusNode: chat.focusNode,
                                  style: const TextStyle(fontSize: 18),
                                  controller: addressDetail.commentController.value,
                                  // onSubmitted: chat.handleSubmitted,
                                  decoration: const InputDecoration.collapsed(hintText: "Viết bình luận..."),
                                  maxLines: 4,
                                  minLines: 1,
                                  autofocus: false,
                                  cursorColor: const Color.fromRGBO(255, 153, 141, 1.0),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 35,
                                    child: IconButton(
                                      icon: const Icon(Icons.camera_alt_outlined),
                                      onPressed: () async {
                                        // await chat.openCamera();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35,
                                    child: IconButton(
                                      icon: const Icon(Icons.image),
                                      onPressed: () async {
                                        // await chat.chooseImage();
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {
                                      HandleUser().addComment(
                                        addressDetail.commentController.value.text,
                                        addressModel.id,
                                        DateFormat('EEEE, yyyy MMMM d, h:mm a').format(DateTime.now()),
                                      );
                                      addressDetail.commentList.insert(
                                          0,
                                          CommentModel(
                                            fullName: DataUser.userModel.value.fullName,
                                            // id: addressModel.id,
                                            imagePath: DataUser.userModel.value.imagePath,
                                            comment: addressDetail.commentController.value.text,
                                            time: DateFormat('EEEE, yyyy MMMM d, h:mm a').format(DateTime.now()),
                                          ));
                                      addressDetail.commentController.value.clear();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppConst.kTransparentGrayColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(top: 50, left: 15),
                child: const Icon(
                  Icons.arrow_back,
                  size: AppConst.kFontSize,
                  color: AppConst.kPrimaryLightColor,
                ),
              ),
            ),
            Positioned(
                top: 50,
                right: 15,
                child: GestureDetector(
                  onTap: () {
                    if (addressDetail.like.value) {
                      HandleUser().unfavoriteLocation(addressModel.id);
                      addressModel.likes -= 1;
                    } else {
                      HandleUser().favoriteLocation(addressModel.id);
                      addressModel.likes += 1;
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppConst.kTransparentGrayColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // margin: const EdgeInsets.only(left: 10),
                    // child: const Icon(Icons.favorite_border_outlined, size: AppConst.kSubFontSize),
                    child: addressDetail.like.value
                        ? const Icon(
                            Icons.favorite,
                            size: AppConst.kFontSize,
                            color: AppConst.kButtonColor,
                          )
                        : const Icon(
                            Icons.favorite_border_outlined,
                            size: AppConst.kFontSize,
                            color: AppConst.kPrimaryLightColor,
                          ),
                  ),
                ))
          ],
        ),
      );
    });
  }

  Future<List<String>> getImageUrlList(String name) async {
    List<String> urlList = [];

    for (int i = 1; i <= 5; i++) {
      var storageRef = FirebaseStorage.instance.ref().child('address/$name$i.jpeg');
      try {
        urlList.add(await storageRef.getDownloadURL());
      } catch (error) {
        print("Error getting image URL: $error");
        urlList.add(AppConst.defaultUrlAddress);
      }
    }
    return urlList;
  }
}
