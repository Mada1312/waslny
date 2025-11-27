// To parse this JSON data, do
//
//     final getDriverShipmentsModel = getDriverShipmentsModelFromJson(jsonString);

import 'dart:convert';

import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';

GetTripDetailsModel getDriverShipmentsModelFromJson(String str) =>
    GetTripDetailsModel.fromJson(json.decode(str));

String getDriverShipmentsModelToJson(GetTripDetailsModel data) =>
    json.encode(data.toJson());

class GetTripDetailsModel {
  DriverTripModel? data;
  String? msg;
  int? status;

  GetTripDetailsModel({this.data, this.msg, this.status});

  factory GetTripDetailsModel.fromJson(Map<String, dynamic> json) =>
      GetTripDetailsModel(
        data: json["data"] == null
            ? null
            : DriverTripModel.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "msg": msg,
    "status": status,
  };
}
