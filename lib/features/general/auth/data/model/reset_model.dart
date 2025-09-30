// To parse this JSON data, do
//
//     final sendCodeRequestModel = sendCodeRequestModelFromJson(jsonString);

import 'dart:convert';

SendCodeRequestModel sendCodeRequestModelFromJson(String str) =>
    SendCodeRequestModel.fromJson(json.decode(str));

String sendCodeRequestModelToJson(SendCodeRequestModel data) =>
    json.encode(data.toJson());

class SendCodeRequestModel {
  SendCodeRequestModelData? data;
  String? msg;
  int? status;

  SendCodeRequestModel({
    this.data,
    this.msg,
    this.status,
  });

  factory SendCodeRequestModel.fromJson(Map<String, dynamic> json) =>
      SendCodeRequestModel(
        data: json["data"] == null
            ? null
            : SendCodeRequestModelData.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "msg": msg,
        "status": status,
      };
}

class SendCodeRequestModelData {
  int? otp;

  SendCodeRequestModelData({
    this.otp,
  });

  factory SendCodeRequestModelData.fromJson(Map<String, dynamic> json) =>
      SendCodeRequestModelData(
        otp: json["otp"],
      );

  Map<String, dynamic> toJson() => {
        "otp": otp,
      };
}
