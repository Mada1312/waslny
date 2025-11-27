// To parse this JSON data, do
//
//     final defaultPostModel = defaultPostModelFromJson(jsonString);

import 'dart:convert';

DefaultPostModel defaultPostModelFromJson(String str) =>
    DefaultPostModel.fromJson(json.decode(str));

String defaultPostModelToJson(DefaultPostModel data) =>
    json.encode(data.toJson());

class DefaultPostModel {
  String? msg;
  int? status;

  DefaultPostModel({
    this.msg,
    this.status,
  });

  factory DefaultPostModel.fromJson(Map<String, dynamic> json) =>
      DefaultPostModel(
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "status": status,
      };
}
