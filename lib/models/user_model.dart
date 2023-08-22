import 'dart:convert';

class UserModel {
  var fullName;
  var email;
  var id;
  var imagePath;
  var phoneNumber;
  var birthDay;
  var sex;
  var address;

  UserModel(this.id, this.email, this.fullName, this.imagePath);

  UserModel.fullInfo(
    this.id,
    this.email,
    this.fullName,
    this.imagePath,
    this.sex,
    this.phoneNumber,
    this.birthDay,
    this.address,
  );

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel.fullInfo(json['id'], json['email'], json['fullName'], json['imagePath'], json['sex'],
        json['phoneNumber'], json['birthDay'], json['address']);
  }
}
