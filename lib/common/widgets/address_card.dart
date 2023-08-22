import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/controllers/resource.dart';
import 'package:tourly/models/address_model.dart'; // Import package to format dates

class AddressCard extends StatelessWidget {
  final AddressModel addressModel;

  const AddressCard(this.addressModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: const Color(0xFFF3F3F3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: Resource().getImageUrl(Resource().convertToSlug(addressModel.name)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Center(child: Text('Error loading image')),
                );
              }

              return Image.network(
                snapshot.data!,
                fit: BoxFit.cover,
                height: 160,
                width: double.infinity,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      addressModel.name,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppConst.kTextColor),
                    ),
                    const Spacer(),
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
                  style: const TextStyle(fontSize: 16.0, color: AppConst.kTextColor),
                ),
                const SizedBox(height: 4.0),
                Text(
                  addressModel.keywords,
                  style: const TextStyle(fontSize: 14.0, color: AppConst.kTextColor, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
