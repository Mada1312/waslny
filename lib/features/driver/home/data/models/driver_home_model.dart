// To parse this JSON data, do
//
//     final getDriverHomeModel = getDriverHomeModelFromJson(jsonString);

import 'dart:convert';

GetDriverHomeModel getDriverHomeModelFromJson(String str) => GetDriverHomeModel.fromJson(json.decode(str));

String getDriverHomeModelToJson(GetDriverHomeModel data) => json.encode(data.toJson());

class GetDriverHomeModel {
    Data? data;
    String? msg;
    int? status;

    GetDriverHomeModel({
        this.data,
        this.msg,
        this.status,
    });

    factory GetDriverHomeModel.fromJson(Map<String, dynamic> json) => GetDriverHomeModel(
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
    DriverTripModel? currentTrip;

    Data({
        this.user,
        this.currentTrip,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        currentTrip: json["current_trip"] == null ? null : DriverTripModel.fromJson(json["current_trip"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "current_trip": currentTrip?.toJson(),
    };
}

class DriverTripModel {
    int? id;
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

    DriverTripModel({
        this.id,
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
    });

    factory DriverTripModel.fromJson(Map<String, dynamic> json) => DriverTripModel(
        id: json["id"],
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
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
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
    };
}

class User {
    int? isActive;
    int? isVerified;
    int? isDataUploaded;

    User({
        this.isActive,
        this.isVerified,
        this.isDataUploaded,
    });

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
