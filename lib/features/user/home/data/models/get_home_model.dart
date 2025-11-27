// To parse this JSON data, do
//
//     final getUserHomeModel = getUserHomeModelFromJson(jsonString);

import 'dart:convert';

GetUserHomeModel getUserHomeModelFromJson(String str) =>
    GetUserHomeModel.fromJson(json.decode(str));

String getUserHomeModelToJson(GetUserHomeModel data) =>
    json.encode(data.toJson());

class GetUserHomeModel {
  GetUserHomeModelData? data;
  String? msg;
  int? status;

  GetUserHomeModel({this.data, this.msg, this.status});

  factory GetUserHomeModel.fromJson(Map<String, dynamic> json) =>
      GetUserHomeModel(
        data: json["data"] == null
            ? null
            : GetUserHomeModelData.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "msg": msg,
    "status": status,
  };
}

class GetUserHomeModelData {
  User? user;
  int? isWebhookVerified;
  List<TripAndServiceModel>? trips;
  List<TripAndServiceModel>? services;
  String? avarageDistance;
  int? unRatedTripId;

  GetUserHomeModelData({
    this.user,
    this.trips,
    this.services,
    this.isWebhookVerified,
    this.avarageDistance,
    this.unRatedTripId,
  });

  factory GetUserHomeModelData.fromJson(Map<String, dynamic> json) =>
      GetUserHomeModelData(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        isWebhookVerified: json["is_webhook_verified"],
        unRatedTripId: json["unrated_trip_id"],
        avarageDistance: json["average_distance"]?.toString().isEmpty == true
            ? '0'
            : json["average_distance"],
        trips: json["trips"] == null
            ? []
            : List<TripAndServiceModel>.from(
                json["trips"]!.map((x) => TripAndServiceModel.fromJson(x)),
              ),
        services: json["services"] == null
            ? []
            : List<TripAndServiceModel>.from(
                json["services"]!.map((x) => TripAndServiceModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "is_webhook_verified": isWebhookVerified,
    "unrated_trip_id": unRatedTripId,
    "average_distance": avarageDistance,
    "trips": trips == null
        ? []
        : List<dynamic>.from(trips!.map((x) => x.toJson())),
    "services": services == null
        ? []
        : List<dynamic>.from(services!.map((x) => x.toJson())),
  };
}

class TripAndServiceModel {
  int? id;
  String? code;
  DateTime? day;
  String? time;
  String? from;
  String? fromLat;
  String? fromLong;
  String? to;
  String? toLat;
  String? distance;
  String? toLong;
  String? type;
  String? serviceToName;
  int? serviceTo;
  dynamic roomToken;
  bool? isFav;
  Driver? driver;
  int? cannotFindDriver;
  int? isDriverArrived;
  int? isUserStartTrip;
  int? isDriverStartTrip;
  int? isUserAccept;
  int? isDriverAccept;
  int? isUserChangeCaptain;
  int? isDriverAnotherTrip;
  int? isService;
  TripAndServiceModel({
    this.id,
    this.code,
    this.day,
    this.time,
    this.from,
    this.fromLat,
    this.fromLong,
    this.to,
    this.distance,
    this.toLat,
    this.toLong,
    this.type,
    this.roomToken,
    this.serviceTo,
    this.driver,
    this.isFav,
    this.serviceToName,
    this.isDriverArrived,
    this.isUserStartTrip,
    this.isDriverStartTrip,
    this.isUserAccept,
    this.isDriverAccept,
    this.isUserChangeCaptain,
    this.isDriverAnotherTrip,
    this.cannotFindDriver,
    this.isService,
  });

  factory TripAndServiceModel.fromJson(Map<String, dynamic> json) =>
      TripAndServiceModel(
        id: json["id"],
        code: json["code"],
        day: json["day"] == null ? null : DateTime.parse(json["day"]),
        time: json["time"],
        serviceTo: json["service_to"],
        isFav: json["is_fav"] == 0 ? false : true,
        from: json["from"],
        distance: json["distance"],
        fromLat: json["from_lat"],
        fromLong: json["from_long"],
        to: json["to"],
        toLat: json["to_lat"],
        toLong: json["to_long"],
        type: json["type"],
        serviceToName: json["service_to_name"],
        roomToken: json["room_token"],
        driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
        cannotFindDriver: json["cannot_find_driver"],
        isDriverArrived: json["is_driver_arrived"],
        isUserStartTrip: json["is_user_start_trip"],
        isDriverStartTrip: json["is_driver_start_trip"],
        isUserAccept: json["is_user_accept"],
        isDriverAccept: json["is_driver_accept"],
        isUserChangeCaptain: json["is_user_change_captain"],
        isDriverAnotherTrip: json["is_driver_another_trip"],
        isService: json["is_service"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "day":
        "${day!.year.toString().padLeft(4, '0')}-${day!.month.toString().padLeft(2, '0')}-${day!.day.toString().padLeft(2, '0')}",
    "time": time,
    "from": from,
    "from_lat": fromLat,
    "service_to": serviceTo,
    "distance": distance,
    "service_to_name": serviceToName,
    "is_fav": isFav,
    "from_long": fromLong,
    "to": to,
    "to_lat": toLat,
    "to_long": toLong,
    "type": type,
    "room_token": roomToken,
    "driver": driver?.toJson(),
    "cannot_find_driver": cannotFindDriver,
    "is_driver_arrived": isDriverArrived,
    "is_user_start_trip": isUserStartTrip,
    "is_driver_start_trip": isDriverStartTrip,
    "is_user_accept": isUserAccept,
    "is_driver_accept": isDriverAccept,
    "is_user_change_captain": isUserChangeCaptain,
    "is_driver_another_trip": isDriverAnotherTrip,
    "is_service": isService,
  };
}

class Driver {
  int? id;
  String? name;
  String? phone;
  String? image;
  String? vehiclePlateNumber;

  Driver({this.id, this.name, this.phone, this.image, this.vehiclePlateNumber});

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    image: json["image"],
    vehiclePlateNumber: json["vehicle_plate_number"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "image": image,

    "vehicle_plate_number": vehiclePlateNumber,
  };
}

class User {
  int? id;
  String? name;
  dynamic address;
  String? image;

  User({this.id, this.name, this.address, this.image});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "image": image,
  };
}
