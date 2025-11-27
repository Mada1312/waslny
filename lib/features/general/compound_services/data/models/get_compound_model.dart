// To parse this JSON data, do
//
//     final getCompoundServicesModel = getCompoundServicesModelFromJson(jsonString);

import 'dart:convert';

GetCompoundServicesModel getCompoundServicesModelFromJson(String str) =>
    GetCompoundServicesModel.fromJson(json.decode(str));

String getCompoundServicesModelToJson(GetCompoundServicesModel data) =>
    json.encode(data.toJson());

class GetCompoundServicesModel {
  List<GetCompoundServicesModelData>? data;
  String? msg;
  int? status;

  GetCompoundServicesModel({this.data, this.msg, this.status});

  factory GetCompoundServicesModel.fromJson(Map<String, dynamic> json) =>
      GetCompoundServicesModel(
        data: json["data"] == null
            ? []
            : List<GetCompoundServicesModelData>.from(
                json["data"]!.map(
                  (x) => GetCompoundServicesModelData.fromJson(x),
                ),
              ),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "msg": msg,
    "status": status,
  };
}

class GetCompoundServicesModelData {
  int? id;
  String? name;
  String? image;
  dynamic phone;
  String? whatsapp;

  GetCompoundServicesModelData({
    this.id,
    this.name,
    this.image,
    this.phone,
    this.whatsapp,
  });

  factory GetCompoundServicesModelData.fromJson(Map<String, dynamic> json) =>
      GetCompoundServicesModelData(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        phone: json["phone"],
        whatsapp: json["whatsapp"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "phone": phone,
    "whatsapp": whatsapp,
  };
}
