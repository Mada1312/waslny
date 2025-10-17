// To parse this JSON data, do
//
//     final getDriverShipmentDetailsModel = getDriverShipmentDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:waslny/features/user/home/data/models/get_home_model.dart';

GetDriverShipmentDetailsModel getDriverShipmentDetailsModelFromJson(
  String str,
) => GetDriverShipmentDetailsModel.fromJson(json.decode(str));

String getDriverShipmentDetailsModelToJson(
  GetDriverShipmentDetailsModel data,
) => json.encode(data.toJson());

class GetDriverShipmentDetailsModel {
  ShipmentDetailsDriverData? data;
  String? msg;
  int? status;

  GetDriverShipmentDetailsModel({this.data, this.msg, this.status});

  factory GetDriverShipmentDetailsModel.fromJson(Map<String, dynamic> json) =>
      GetDriverShipmentDetailsModel(
        data: json["data"] == null
            ? null
            : ShipmentDetailsDriverData.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "msg": msg,
    "status": status,
  };
}

class ShipmentDetailsDriverData {
  int? id;
  String? code;
  String? from;
  ToCountry? toCountry;
  ToCountry? truckType;
  Driver? user;
  Driver? driver;
  dynamic roomToken;
  int? loadSizeFrom;
  int? loadSizeTo;
  String? goodsType;
  String? shipmentDateTime;
  String? shipmentDateTimeDiff;
  String? description;
  int? status;
  String? statusName;
  dynamic driverStatus;
  dynamic driverStatusName;
  String? inProgressAt;
  List<ShipmentTracking>? shipmentTracking;
  bool? isRate;
  String? lat;
  String? long;
  int? driverIsDeliverd;
  int? exporterIsDeliverd;

  ShipmentDetailsDriverData({
    this.id,
    this.code,
    this.from,
    this.toCountry,
    this.truckType,
    this.user,
    this.driver,
    this.roomToken,
    this.loadSizeFrom,
    this.loadSizeTo,
    this.goodsType,
    this.shipmentDateTime,
    this.shipmentDateTimeDiff,
    this.description,
    this.status,
    this.statusName,
    this.driverStatus,
    this.driverStatusName,
    this.inProgressAt,
    this.shipmentTracking,
    this.isRate,
    this.lat,
    this.long,
    this.driverIsDeliverd,
    this.exporterIsDeliverd,
  });

  factory ShipmentDetailsDriverData.fromJson(Map<String, dynamic> json) =>
      ShipmentDetailsDriverData(
        id: json["id"],
        code: json["code"],
        from: json["from"],
        toCountry: json["to_country"] == null
            ? null
            : ToCountry.fromJson(json["to_country"]),
        truckType: json["truck_type"] == null
            ? null
            : ToCountry.fromJson(json["truck_type"]),
        user: json["user"] == null ? null : Driver.fromJson(json["user"]),
        driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
        roomToken: json["room_token"],
        loadSizeFrom: json["load_size_from"],
        loadSizeTo: json["load_size_to"],
        goodsType: json["goods_type"],
        shipmentDateTime: json["shipment_date_time"],
        shipmentDateTimeDiff: json["shipment_date_time_diff"],
        description: json["description"],
        status: json["status"],
        statusName: json["status_name"],
        driverStatus: json["driver_status"],
        driverStatusName: json["driver_status_name"],
        inProgressAt: json["in_progress_at"],
        isRate: json["is_rate"],
        lat: json["lat"],
        long: json["long"],
        driverIsDeliverd: json["driver_is_delivered"],
        exporterIsDeliverd: json["exporter_is_delivered"],
        shipmentTracking: json["shipment_tracking"] == null
            ? []
            : List<ShipmentTracking>.from(
                json["shipment_tracking"]!.map(
                  (x) => ShipmentTracking.fromJson(x),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "from": from,
    "to_country": toCountry?.toJson(),
    "truck_type": truckType?.toJson(),
    "user": user?.toJson(),
    "driver": driver?.toJson(),
    "room_token": roomToken,
    "load_size_from": loadSizeFrom,
    "load_size_to": loadSizeTo,
    "goods_type": goodsType,
    "shipment_date_time": shipmentDateTime,
    "shipment_date_time_diff": shipmentDateTimeDiff,
    "description": description,
    "status": status,
    "status_name": statusName,
    "driver_status": driverStatus,
    "driver_status_name": driverStatusName,
    "in_progress_at": inProgressAt,
    "driver_is_delivered": driverIsDeliverd,
    "exporter_is_delivered": exporterIsDeliverd,
    "is_rate": isRate,
    "lat": lat,
    "long": long,
    "shipment_tracking": shipmentTracking == null
        ? []
        : List<dynamic>.from(shipmentTracking!.map((x) => x.toJson())),
  };
}

class ShipmentTracking {
  int? id;
  String? location;
  String? lat;
  String? long;
  String? createdAt;

  ShipmentTracking({
    this.id,
    this.location,
    this.createdAt,
    this.lat,
    this.long,
  });

  factory ShipmentTracking.fromJson(Map<String, dynamic> json) =>
      ShipmentTracking(
        id: json["id"],
        location: json["location"],
        lat: json["lat"],
        long: json["long"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "location": location,
    "lat": lat,
    "long": long,
    "created_at": createdAt,
  };
}

class ToCountry {
  int? id;
  String? name;

  ToCountry({this.id, this.name});

  factory ToCountry.fromJson(Map<String, dynamic> json) =>
      ToCountry(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
