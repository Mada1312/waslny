// To parse this JSON data, do
//
//     final getDriverHomeModel = getDriverHomeModelFromJson(jsonString);

import 'dart:convert';

import 'package:waslny/features/driver/trips/screens/data/models/shipment_details_model.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

GetDriverHomeModel getDriverHomeModelFromJson(String str) =>
    GetDriverHomeModel.fromJson(json.decode(str));

String getDriverHomeModelToJson(GetDriverHomeModel data) =>
    json.encode(data.toJson());

class GetDriverHomeModel {
  Data? data;
  String? msg;
  int? status;
  GetDriverHomeModel({this.data, this.msg, this.status});
  factory GetDriverHomeModel.fromJson(Map<String, dynamic> json) =>
      GetDriverHomeModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );
  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "msg": msg,
    "status": status,
  };
}

class Data {
  User? user;
  ScheduleTrip? scheduleTrip;
  dynamic currentTrip;
  Data({this.user, this.scheduleTrip, this.currentTrip});
  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    scheduleTrip: json["schedule_trip"] == null
        ? null
        : ScheduleTrip.fromJson(json["schedule_trip"]),
    currentTrip: json["current_trip"],
  );
  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "schedule_trip": scheduleTrip?.toJson(),
    "current_trip": currentTrip,
  };
}

class ScheduleTrip {
  int? id;
  DateTime? day;
  String? time;
  String? type;

  ScheduleTrip({this.id, this.day, this.time, this.type});

  factory ScheduleTrip.fromJson(Map<String, dynamic> json) => ScheduleTrip(
    id: json["id"],
    day: json["day"] == null ? null : DateTime.parse(json["day"]),
    time: json["time"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day":
        "${day!.year.toString().padLeft(4, '0')}-${day!.month.toString().padLeft(2, '0')}-${day!.day.toString().padLeft(2, '0')}",
    "time": time,
    "type": type,
  };
}

class User {
  int? isActive;
  int? isVerified;
  int? isDataUploaded;

  User({this.isActive, this.isVerified, this.isDataUploaded});

  factory User.fromJson(Map<String, dynamic> json) => User(
    isActive: json["is_active"],
    isVerified: json["is_verified"],
    isDataUploaded: json["is_data_uploaded"],
  );

  Map<String, dynamic> toJson() => {
    "is_active": isActive,
    "is_verified": isVerified,
    "is_data_uploaded": isDataUploaded,
  };
}

class ShipmentDriverModel {
  int? id;
  String? from;
  String? code;
  ToCountry? toCountry;
  String? lat;
  String? long;

  Driver? user;

  dynamic roomToken;

  String? shipmentDateTime;
  // String? truckType;
  String? goodsType;

  int? status;
  String? statusName;
  int? driverStatus;
  // null not applied yet, 0 in progress
  String? driverStatusName;
  ShipmentDriverModel({
    this.id,
    this.from,
    this.code,
    this.toCountry,
    this.user,
    this.roomToken,
    this.shipmentDateTime,
    this.status,
    this.driverStatus,
    this.driverStatusName,
    // this.truckType,
    this.goodsType,
    this.statusName,
    this.lat,
    this.long,
  });

  factory ShipmentDriverModel.fromJson(Map<String, dynamic> json) =>
      ShipmentDriverModel(
        id: json["id"],
        from: json["from"],
        code: json["code"],
        toCountry: json["to_country"] == null
            ? null
            : ToCountry.fromJson(json["to_country"]),
        user: json["user"] == null ? null : Driver.fromJson(json["user"]),
        roomToken: json["room_token"],
        shipmentDateTime: json["shipment_date_time"],
        status: json["status"],
        statusName: json["status_name"],
        driverStatus: json["driver_status"],
        driverStatusName: json["driver_status_name"],
        // truckType: json["truck_type"],
        goodsType: json["goods_type"],
        lat: json["lat"],
        long: json["long"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "from": from,
    "code": code,
    "to_country": toCountry?.toJson(),
    "user": user?.toJson(),
    "room_token": roomToken,
    "shipment_date_time": shipmentDateTime,
    "status": status,
    "status_name": statusName,
    "driver_status": driverStatus,
    "driver_status_name": driverStatusName,
    // "truck_type": truckType,
    "goods_type": goodsType,
    "lat": lat,
    "long": long,
  };
}
