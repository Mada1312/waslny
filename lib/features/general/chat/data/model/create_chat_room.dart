class MainCreateChatRoomModel {
  Data? data;
  String? msg;
  int? status;

  MainCreateChatRoomModel({
    this.data,
    this.msg,
    this.status,
  });

  factory MainCreateChatRoomModel.fromJson(Map<String, dynamic> json) =>
      MainCreateChatRoomModel(
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
  int? id;
  int? shipmentId;
  int? driverId;
  String? roomToken;

  Data({
    this.id,
    this.shipmentId,
    this.driverId,
    this.roomToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        shipmentId: json["shipment_id"],
        driverId: json["driver_id"],
        roomToken: json["room_token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shipment_id": shipmentId,
        "driver_id": driverId,
        "room_token": roomToken,
      };
}
