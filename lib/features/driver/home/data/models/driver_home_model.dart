// To parse this JSON data, do
//
//     final getDriverHomeModel = getDriverHomeModelFromJson(jsonString);

import 'dart:convert';

import 'package:waslny/features/general/chat/data/model/room_model.dart';

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
  int? isWebhookVerified;
  DriverTripModel? currentTrip;

  Data({this.user, this.currentTrip, this.isWebhookVerified});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    isWebhookVerified: json["is_webhook_verified"],
    currentTrip: json["current_trip"] == null
        ? null
        : DriverTripModel.fromJson(json["current_trip"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "is_webhook_verified": isWebhookVerified,
    "current_trip": currentTrip?.toJson(),
  };
}

class DriverTripModel {
  int? id;
  int? driverId;
  int? userId;
  String? code;
  String? day;
  String? time;
  String? from;
  String? fromLat;
  String? fromLong;
  String? to;
  String? toLat;
  String? toLong;
  String? description;
  String? type;
  String? statusName;
  int? status;
  String? roomToken;
  int? isDriverArrived;
  int? isUserStartTrip;
  int? isDriverStartTrip;
  int? isUserAccept;
  int? isDriverAccept;
  int? isUserChangeCaptain;
  int? isDriverAnotherTrip;
  String? serviceToName;
  int? serviceTo;
  Driver? driver;
  Driver? user;
  int? isService;
  String? distance;
  DriverTripModel({
    this.id,
    this.driverId,
    this.userId,
    this.code,
    this.day,
    this.time,
    this.from,
    this.fromLat,
    this.fromLong,
    this.to,
    this.toLat,
    this.toLong,
    this.description,
    this.type,
    this.statusName,
    this.status,
    this.roomToken,
    this.isDriverArrived,
    this.isUserStartTrip,
    this.isDriverStartTrip,
    this.isUserAccept,
    this.isDriverAccept,
    this.isUserChangeCaptain,
    this.isDriverAnotherTrip,
    this.driver,
    this.user,
    this.serviceToName,
    this.serviceTo,
    this.isService,
    this.distance,
  });

  factory DriverTripModel.fromJson(Map<String, dynamic> json) =>
      DriverTripModel(
        id: json["id"],
        serviceTo: json["service_to"],
        serviceToName: json["service_to_name"],
        driverId: json["driver_id"],
        userId: json["user_id"],
        code: json["code"],
        day: json["day"],
        time: json["time"],
        from: json["from"],
        fromLat: json["from_lat"],
        fromLong: json["from_long"],
        to: json["to"],
        toLat: json["to_lat"],
        toLong: json["to_long"],
        description: json["description"],
        type: json["type"].toString(),
        statusName: json["status_name"],
        status: json["status"],
        roomToken: json["room_token"],
        isDriverArrived: json["is_driver_arrived"],
        isUserStartTrip: json["is_user_start_trip"],
        isDriverStartTrip: json["is_driver_start_trip"],
        isUserAccept: json["is_user_accept"],
        isDriverAccept: json["is_driver_accept"],
        isUserChangeCaptain: json["is_user_change_captain"],
        isDriverAnotherTrip: json["is_driver_another_trip"],
        driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
        user: json["user"] == null ? null : Driver.fromJson(json["user"]),
        isService: json["is_service"],
        distance: json["distance"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "driver_id": driverId,
    "user_id": userId,
    "code": code,
    "day": day,
    "time": time,
    "from": from,
    "from_lat": fromLat,
    "from_long": fromLong,
    "to": to,
    "to_lat": toLat,
    "to_long": toLong,
    "description": description,
    "type": type,
    "status_name": statusName,
    "status": status,
    "room_token": roomToken,
    "is_driver_arrived": isDriverArrived,
    "is_user_start_trip": isUserStartTrip,
    "is_driver_start_trip": isDriverStartTrip,
    "is_user_accept": isUserAccept,
    "is_driver_accept": isDriverAccept,
    "is_user_change_captain": isUserChangeCaptain,
    "is_driver_another_trip": isDriverAnotherTrip,
    "driver": driver?.toJson(),
    "user": user?.toJson(),
    "service_to": serviceTo,
    "service_to_name": serviceToName,
    "is_service": isService,
    "distance": distance,
  };
}

class User {
  int? id; // ✅ معرف السائق
  String? phone; // ✅ رقم الهاتف
  String? name; // ✅ اسم السائق
  int? isActive;
  int? isVerified;
  int? isDataUploaded;
  String? userType;

  User({
    this.id,
    this.phone,
    this.name,
    this.isActive,
    this.isVerified,
    this.isDataUploaded,
    this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    phone: json["phone"],
    name: json["name"],
    isActive: json["is_active"],
    isVerified: json["is_verified"],
    isDataUploaded: json["is_data_uploaded"],
    userType: json["user_type"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "phone": phone,
    "name": name,
    "is_active": isActive,
    "is_verified": isVerified,
    "is_data_uploaded": isDataUploaded,
    "user_type": userType,
  };
}
