import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/controllers/resource.dart';
import 'package:tourly/common/widgets/app_image.dart';
import 'package:tourly/models/address_model.dart'; // Import package to format dates

class AddressCard extends StatelessWidget {
  final AddressModel addressModel;

  const AddressCard(this.addressModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<String>(
          future: Resource().getImageUrl(Resource().convertToSlug(addressModel.name)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: Get.size.width * 0.66,
                width: Get.size.width * 0.88,
                child: const CupertinoActivityIndicator(),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: Get.size.width * 0.66,
                width: Get.size.width * 0.88,
                child: const CupertinoActivityIndicator(),
              );
            }
            return AppImage(
              snapshot.data!,
              Get.size.width * 0.88,
              Get.size.width * 0.66,
              circular: Get.size.width * 0.04,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      addressModel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppConst.kTextColor),
                    ),
                  ),
                  const Icon(
                    Icons.favorite_border_outlined,
                    size: 20,
                  ),
                  Text(
                    ' ${addressModel.like}',
                    style: const TextStyle(fontSize: 16.0, color: AppConst.kTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                addressModel.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16.0, color: AppConst.kSubTextColor),
              ),
              const SizedBox(height: 4.0),
              Text(
                addressModel.keywords,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14.0, color: AppConst.kTextColor, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ],
    );
  }
}
