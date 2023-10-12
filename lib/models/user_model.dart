// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

UserModel userFromJson(String str) => UserModel.fromJson(json.decode(str));

String userToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  late String fullName;
  late String email;
  final String id;
  late String imagePath;
  late String sex;
  late String phoneNumber;
  late String birthDay;
  late String address;
  final String loginWith;

  UserModel(
      {required this.fullName,
      required this.email,
      required this.id,
      required this.imagePath,
      required this.sex,
      required this.phoneNumber,
      required this.birthDay,
      required this.address,
      required this.loginWith});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        fullName: json["fullName"] ?? '',
        email: json["email"] ?? '',
        id: json["id"] ?? '',
        imagePath: json["imagePath"] ?? '',
        sex: json["sex"] ?? '',
        phoneNumber: json["phoneNumber"] ?? '',
        birthDay: json["birthDay"] ?? '',
        address: json["address"] ?? '',
        loginWith: json["loginWith"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "email": email,
        "id": id,
        "imagePath": imagePath,
        "sex": sex,
        "phoneNumber": phoneNumber,
        "birthDay": birthDay,
        "address": address,
        "loginWith": loginWith
      };
}
