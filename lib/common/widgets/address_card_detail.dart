import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/controllers/resource.dart';
import 'package:tourly/common/widgets/carousel_slider_custom.dart';
import 'package:tourly/models/address_model.dart';

class AddressCardDetail extends StatelessWidget {
  const AddressCardDetail({super.key, required this.addressModel});

  final AddressModel addressModel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<String>>(
                future: getImageUrlList(Resource().convertToSlug(addressModel.name)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: null,
                    );
                  }
                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: null,
                    );
                  }

                  return CarouselSliderCustom(
                    imageUrls: snapshot.data!.isEmpty ? [AppConst.defaultUrlAddress] : snapshot.data!,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addressModel.name,
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      addressModel.keywords,
                      style: const TextStyle(fontSize: 14.0, color: AppConst.kTextColor, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${addressModel.like}  ·  ',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Icon(
                          Icons.comment_outlined,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Colors.black,
                            width: 1, // Underline thickness
                          ))),
                          child: const Text(
                            '1 Bình luận',
                            style: TextStyle(
                              // decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                              decorationThickness: 2,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(
                      thickness: 1,
                      color: Colors.black.withOpacity(0.15),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      addressModel.describe.replaceAll('  ', '\n\n'),
                      style: TextStyle(fontSize: AppConst.kFontSize),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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
