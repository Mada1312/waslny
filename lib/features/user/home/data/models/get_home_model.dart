
import 'dart:convert';

GetUserHomeModel getUserHomeModelFromJson(String str) =>
    GetUserHomeModel.fromJson(json.decode(str));

String getUserHomeModelToJson(GetUserHomeModel data) =>
    json.encode(data.toJson());

class GetUserHomeModel {
  Data? data;
  String? msg;
  int? status;

  GetUserHomeModel({
    this.data,
    this.msg,
    this.status,
  });

  factory GetUserHomeModel.fromJson(Map<String, dynamic> json) =>
      GetUserHomeModel(
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
  List<ShipmentModel>? shipments;
  int? totalDrivers;
  int? totalShipments;
  Data({
    this.user,
    this.shipments,
    this.totalDrivers,
    this.totalShipments,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        totalDrivers: json["total_drivers"],
        totalShipments: json["total_shipments"],
        shipments: json["shipments"] == null
            ? null
            : List<ShipmentModel>.from(
                json["shipments"].map((x) => ShipmentModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "total_drivers": totalDrivers,
        "total_shipments": totalShipments,
        "shipments": shipments == null
            ? null
            : List<dynamic>.from(shipments!.map((x) => x.toJson())),
      };
}

class User {
  int? id;
  String? name;
  String? phone;
  dynamic exportCard;
  int? isVerified;

  User({
    this.id,
    this.name,
    this.phone,
    this.exportCard,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        exportCard: json["export_card"],
        isVerified: json["is_verified"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "export_card": exportCard,
        "is_verified": isVerified,
      };
}

class ShipmentModel {
  int? id;
  String? day;
  String? time;
  String? from;
  String? to;
  String? code;
  String? goodsType;
  String? truckType;
  DriverOrUserModel? driver;
  String? lat;
  String? long;

  ShipmentModel({
    this.id,
    this.day,
    this.time,
    this.from,
    this.to,
    this.code,
    this.driver,
    this.goodsType,
    this.truckType,
    this.lat,
    this.long,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) => ShipmentModel(
        id: json["id"],
        day: json["day"],
        time: json["time"],
        from: json["from"],
        to: json["to"],
        code: json["code"],
        goodsType: json["goods_type"],
        truckType: json["truck_type"],
        lat: json["lat"],
        long: json["long"],
        driver: json["driver"] == null
            ? null
            : DriverOrUserModel.fromJson(json["driver"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "day": day,
        "time": time,
        "from": from,
        "to": to,
        "code": code,
        "goods_type": goodsType,
        "truck_type": truckType,
        "lat": lat,
        "long": long,
        "driver": driver?.toJson(),
      };
}

class DriverOrUserModel {
  int? id;
  int? driverId;
  String? name;
  dynamic phone;
  dynamic image;
  bool? isFav;

  DriverOrUserModel({
    this.id,
    this.driverId,
    this.name,
    this.phone,
    this.image,
    this.isFav,
  });

  factory DriverOrUserModel.fromJson(Map<String, dynamic> json) =>
      DriverOrUserModel(
        id: json["id"],
        driverId: json["driver_id"],
        name: json["name"],
        phone: json["phone"],
        image: json["image"],
        isFav: json["is_fav"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "driver_id": driverId,
        "name": name,
        "phone": phone,
        "image": image,
        "is_fav": isFav,
      };
}
