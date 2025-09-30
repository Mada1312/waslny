// To parse this JSON data, do
//
//     final getNotificationsModel = getNotificationsModelFromJson(jsonString);

import 'dart:convert';

GetNotificationsModel getNotificationsModelFromJson(String str) =>
    GetNotificationsModel.fromJson(json.decode(str));

String getNotificationsModelToJson(GetNotificationsModel data) =>
    json.encode(data.toJson());

class GetNotificationsModel {
  String? msg;
  List<NotificationModel>? data;
  int? status;

  GetNotificationsModel({
    this.msg,
    this.data,
    this.status,
  });

  factory GetNotificationsModel.fromJson(Map<String, dynamic> json) =>
      GetNotificationsModel(
        msg: json["msg"],
        data: json["data"] == null
            ? []
            : List<NotificationModel>.from(
                json["data"]!.map((x) => NotificationModel.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
      };
}

class NotificationModel {
  int? id;
  String? title;
  int? isSeen;
  String? body;
  int? referenceId;
  String? referenceTable;
  String? referenceLink;
  String? createdAt;
  int? isCurrent;
  int? hasShipment;

  NotificationModel({
    this.id,
    this.title,
    this.isSeen,
    this.body,
    this.referenceId,
    this.referenceTable,
    this.referenceLink,
    this.createdAt,
    this.isCurrent,
    this.hasShipment,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        title: json["title"],
        isSeen: json["is_seen"],
        body: json["body"],
        referenceId: json["reference_id"],
        referenceTable: json["reference_table"],
        referenceLink: json["reference_link"],
        createdAt: json["created_at"],
        isCurrent: json["is_current"],
        hasShipment: json["has_shipment"] ,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "is_seen": isSeen,
        "body": body,
        "reference_id": referenceId,
        "reference_table": referenceTable,
        "reference_link": referenceLink,
        "created_at": createdAt,
        "is_current": isCurrent,
        "has_shipment": hasShipment,
      };
}
