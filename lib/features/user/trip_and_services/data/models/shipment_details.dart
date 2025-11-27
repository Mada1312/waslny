import 'dart:convert';

import 'package:waslny/features/driver/trips/data/models/shipment_details_model.dart';
import 'package:waslny/features/user/add_new_trip/data/models/countries_and_types_model.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

GetUserShipmentDetailsModel getUserShipmentDetailsModelFromJson(String str) =>
    GetUserShipmentDetailsModel.fromJson(json.decode(str));

String getUserShipmentDetailsModelToJson(GetUserShipmentDetailsModel data) =>
    json.encode(data.toJson());

class GetUserShipmentDetailsModel {
  UserShipmentData? data;
  String? msg;
  int? status;

  GetUserShipmentDetailsModel({this.data, this.msg, this.status});

  factory GetUserShipmentDetailsModel.fromJson(Map<String, dynamic> json) =>
      GetUserShipmentDetailsModel(
        data: json["data"] == null
            ? null
            : UserShipmentData.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "msg": msg,
    "status": status,
  };
}

class UserShipmentData {
  int? id;
  int? daysLeft;
  String? code;
  Driver? driver;
  int? isNotify;

  String? inProgressAt;
  String? shipmentDateTimeDiff;
  String? shipmentDateTime;
  String? from;

  GetCountriesAndTruckTypeModelData? truckType;
  GetCountriesAndTruckTypeModelData? to;
  String? size;
  num? toSize;
  num? fromSize;
  String? day;
  String? time;
  String? goodsType;
  String? description;
  String? status;
  String? statusName;
  List<Driver>? shipmentDriversRequests;
  List<ShipmentTracking>? shipmentLocations;
  bool? isRated;
  String? lat;
  String? long;
  int? driverIsDeliverd;
  int? exporterIsDeliverd;
  UserShipmentData({
    this.id,
    this.daysLeft,
    this.driver,
    this.code,
    this.isNotify,
    this.inProgressAt,
    this.shipmentDateTimeDiff,
    this.shipmentDateTime,
    this.from,
    this.truckType,
    this.size,
    this.toSize,
    this.fromSize,
    this.day,
    this.time,
    this.goodsType,
    this.description,
    this.status,
    this.statusName,
    this.shipmentDriversRequests,
    this.shipmentLocations,
    this.isRated,
    this.to,
    this.lat,
    this.long,
    this.driverIsDeliverd,
    this.exporterIsDeliverd,
  });

  factory UserShipmentData.fromJson(Map<String, dynamic> json) =>
      UserShipmentData(
        id: json["id"],
        daysLeft: json["days_left"],
        driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
        code: json["code"],
        isNotify: json["is_notify"],
        inProgressAt: json["in_progress_at"],
        shipmentDateTimeDiff: json["shipment_date_time_diff"],
        shipmentDateTime: json["shipment_date_time"],
        driverIsDeliverd: json["driver_is_delivered"],
        exporterIsDeliverd: json["exporter_is_delivered"],
        from: json["from"],
        truckType: json["truck_type"] == null
            ? null
            : GetCountriesAndTruckTypeModelData.fromJson(json["truck_type"]),
        to: json["to"] == null
            ? null
            : GetCountriesAndTruckTypeModelData.fromJson(json["to"]),
        size: json["size"],
        toSize: json["to_size"],
        fromSize: json["from_size"],
        day: json["day"],
        time: json["time"],
        goodsType: json["goods_type"],
        description: json["description"],
        status: json["status"],
        statusName: json["status_name"],
        shipmentDriversRequests: json["shipment_drivers_requests"] == null
            ? []
            : List<Driver>.from(
                json["shipment_drivers_requests"]!.map(
                  (x) => Driver.fromJson(x),
                ),
              ),
        shipmentLocations: json["shipment_locations"] == null
            ? []
            : List<ShipmentTracking>.from(
                json["shipment_locations"]!.map(
                  (x) => ShipmentTracking.fromJson(x),
                ),
              ),
        isRated: json["is_rated"],
        lat: json["lat"],
        long: json["long"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "days_left": daysLeft,
    "driver": driver?.toJson(),
    "code": code,
    "is_notify": isNotify,
    "in_progress_at": inProgressAt,
    "shipment_date_time_diff": shipmentDateTimeDiff,
    "shipment_date_time": shipmentDateTime,
    "from": from,
    "to": to?.toJson(),
    "truck_type": truckType?.toJson(),
    "size": size,
    "to_size": toSize,
    "from_size": fromSize,
    "day": day,
    "time": time,
    "goods_type": goodsType,
    "description": description,
    "status": status,
    "status_name": statusName,
    "shipment_drivers_requests": shipmentDriversRequests == null
        ? []
        : List<dynamic>.from(shipmentDriversRequests!.map((x) => x.toJson())),
    "shipment_locations": shipmentLocations == null
        ? []
        : List<dynamic>.from(shipmentLocations!.map((x) => x.toJson())),
    "is_rated": isRated,
    "lat": lat,
    "long": long,
  };
}
