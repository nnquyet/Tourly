import 'dart:convert';

AddressModel addressModelFromJson(String str) => AddressModel.fromJson(json.decode(str));

String addressModelToJson(AddressModel data) => json.encode(data.toJson());

class AddressModel {
  String name;
  String address;
  String keywords;
  String describe;
  int like;

  AddressModel({
    required this.name,
    required this.address,
    required this.keywords,
    required this.describe,
    required this.like,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        name: json["name"],
        address: json["address"],
        keywords: json["keywords"],
        describe: json["describe"],
        like: json["like"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
        "keywords": keywords,
        "describe": describe,
        "like": like,
      };
}
