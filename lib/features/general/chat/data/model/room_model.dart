class ChatRoomModel {
  List<ChatRoomModelData>? data;
  String? msg;
  int? status;

  ChatRoomModel({this.data, this.msg, this.status});

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) => ChatRoomModel(
    data: json["data"] == null
        ? []
        : List<ChatRoomModelData>.from(
            json["data"]!.map((x) => ChatRoomModelData.fromJson(x)),
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

class ChatRoomModelData {
  int? id;
  int? shipmentId;
  String? shipmentCode;
  Driver? driver;
  Driver? user;
  String? roomToken;

  ChatRoomModelData({
    this.id,
    this.shipmentId,
    this.shipmentCode,
    this.driver,
    this.user,
    this.roomToken,
  });

  factory ChatRoomModelData.fromJson(Map<String, dynamic> json) =>
      ChatRoomModelData(
        id: json["id"],
        shipmentId: json["trip_id"],
        shipmentCode: json["trip_code"],
        driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
        user: json["user"] == null ? null : Driver.fromJson(json["user"]),
        roomToken: json["room_token"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "trip_id": shipmentId,
    "trip_code": shipmentCode,
    "driver": driver?.toJson(),
    "user": user?.toJson(),
    "room_token": roomToken,
  };
}

class Driver {
  int? id;
  String? name;
  String? phone;
  String? image;

  Driver({this.id, this.name, this.phone, this.image});

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "image": image,
  };
}
