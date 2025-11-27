// To parse this JSON data, do
//
//     final getShipmentsModel = getShipmentsModelFromJson(jsonString);

import 'dart:convert';

import 'package:waslny/features/user/home/data/models/get_home_model.dart';

GetShipmentsModel getShipmentsModelFromJson(String str) =>
    GetShipmentsModel.fromJson(json.decode(str));

String getShipmentsModelToJson(GetShipmentsModel data) =>
    json.encode(data.toJson());

class GetShipmentsModel {
  List<TripAndServiceModel>? data;
  String? msg;
  int? status;

  GetShipmentsModel({this.data, this.msg, this.status});

  factory GetShipmentsModel.fromJson(Map<String, dynamic> json) =>
      GetShipmentsModel(
        data: json["data"] == null
            ? []
            : List<TripAndServiceModel>.from(
                json["data"]!.map((x) => TripAndServiceModel.fromJson(x)),
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
