import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tourly/controllers/home_page_controller/search_page_controller.dart';
import 'package:tourly/models/address_model.dart';

class HandleUser {
  final SearchPageController search = Get.find();

  Future<void> addInfoUser(
      String fullName, String email, String id, String phoneNumber, String sex, String birthDay, String address,
      {required File? imageFile}) async {
    final userRef = FirebaseFirestore.instance.collection('0users').doc(email);
    final Reference storageReference = FirebaseStorage.instance.ref().child('images/${id}.jpg');

    if (imageFile != null) {
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
    } else {
      final http.Response response = await http
          .get(Uri.parse('https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg'));
      final Uint8List imageData = response.bodyBytes;
      final UploadTask uploadTask = storageReference.putData(imageData);
      await uploadTask;
    }

    final String downloadURL = await storageReference.getDownloadURL();

    // Lưu trữ thông tin người dùng vào Firestore
    await userRef.set({
      'fullName': fullName,
      'email': email,
      'imagePath': downloadURL,
      'id': id,
      'phoneNumber': phoneNumber,
      'sex': sex,
      'birthDay': birthDay,
      'address': address,
      // 'update': update,
    });
  }

  Future<void> getDataFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Hà Nội').get();

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        AddressModel addressModel = AddressModel.fromJson(data);
        search.addressList.add(addressModel);
      }
    }
    search.filterAddressList.addAll(search.addressList);
  }
}
