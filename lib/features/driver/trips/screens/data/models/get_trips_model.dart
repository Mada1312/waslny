// To parse this JSON data, do
//
//     final getDriverShipmentsModel = getDriverShipmentsModelFromJson(jsonString);

import 'dart:convert';

import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';

GetDriverTripsModel getDriverShipmentsModelFromJson(String str) =>
    GetDriverTripsModel.fromJson(json.decode(str));

String getDriverShipmentsModelToJson(GetDriverTripsModel data) =>
    json.encode(data.toJson());

class GetDriverTripsModel {
  List<DriverTripModel>? data;
  String? msg;
  int? status;

  GetDriverTripsModel({this.data, this.msg, this.status});

  factory GetDriverTripsModel.fromJson(Map<String, dynamic> json) =>
      GetDriverTripsModel(
        data: json["data"] == null
            ? []
            : List<DriverTripModel>.from(
                json["data"]!.map((x) => DriverTripModel.fromJson(x)),
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
