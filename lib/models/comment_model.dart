// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

CommentModel userFromJson(String str) => CommentModel.fromJson(json.decode(str));

String userToJson(CommentModel data) => json.encode(data.toJson());

class CommentModel {
  String fullName;
  String imagePath;
  String comment;
  String time;

  CommentModel({
    required this.fullName,
    required this.imagePath,
    required this.comment,
    required this.time,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        fullName: json["fullName"] ?? '',
        imagePath: json["imagePath"] ?? '',
        comment: json["comment"] ?? '',
        time: json["time"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "imagePath": imagePath,
        "comment": comment,
        "time": time,
      };
}
