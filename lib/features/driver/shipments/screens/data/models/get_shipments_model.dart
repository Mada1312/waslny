// To parse this JSON data, do
//
//     final getDriverShipmentsModel = getDriverShipmentsModelFromJson(jsonString);

import 'dart:convert';

import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';

GetDriverShipmentsModel getDriverShipmentsModelFromJson(String str) =>
    GetDriverShipmentsModel.fromJson(json.decode(str));

String getDriverShipmentsModelToJson(GetDriverShipmentsModel data) =>
    json.encode(data.toJson());

class GetDriverShipmentsModel {
  List<ShipmentDriverModel>? data;
  String? msg;
  int? status;

  GetDriverShipmentsModel({
    this.data,
    this.msg,
    this.status,
  });

  factory GetDriverShipmentsModel.fromJson(Map<String, dynamic> json) =>
      GetDriverShipmentsModel(
        data: json["data"] == null
            ? []
            : List<ShipmentDriverModel>.from(
                json["data"]!.map((x) => ShipmentDriverModel.fromJson(x))),
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
