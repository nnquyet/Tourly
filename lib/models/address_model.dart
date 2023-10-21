// import 'dart:convert';
//
// AddressModel addressModelFromJson(String str) => AddressModel.fromJson(json.decode(str));
//
// String addressModelToJson(AddressModel data) => json.encode(data.toJson());

class AddressModel {
  String name;
  String address;
  String keywords;
  String describe;
  int likes;
  int views;
  String id;
  List<String>? urlList;

  AddressModel({
    required this.name,
    required this.address,
    required this.keywords,
    required this.describe,
    required this.likes,
    required this.views,
    required this.id,
    this.urlList,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json, String idLocation) => AddressModel(
        name: json["name"],
        address: json["address"],
        keywords: json["keywords"],
        describe: json["describe"],
        likes: json["likes"],
        views: json["views"],
        id: idLocation,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
        "keywords": keywords,
        "describe": describe,
        "likes": likes,
        "views": views,
      };
}
