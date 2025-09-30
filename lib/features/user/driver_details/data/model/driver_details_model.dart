class DriverDetailsModel {
  DriverDetailsModelData? data;
  String? msg;
  int? status;

  DriverDetailsModel({
    this.data,
    this.msg,
    this.status,
  });

  factory DriverDetailsModel.fromJson(Map<String, dynamic> json) =>
      DriverDetailsModel(
        data: (json["data"] == null || json["status"] != 200)
            ? null
            : DriverDetailsModelData.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "msg": msg,
        "status": status,
      };
}

class DriverDetailsModelData {
  int? id;
  String? name;
  String? phone;
  String? image;
  int? isVerified;
  int? status;
  int? totalRates;
  String? averageRates;
  TruckType? truckType;
  int? totalShipments;
  List<TruckType>? countries;

  DriverDetailsModelData({
    this.id,
    this.name,
    this.phone,
    this.image,
    this.isVerified,
    this.status,
    this.totalRates,
    this.averageRates,
    this.truckType,
    this.totalShipments,
    this.countries,
  });

  factory DriverDetailsModelData.fromJson(Map<String, dynamic> json) =>
      DriverDetailsModelData(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        image: json["image"],
        isVerified: json["is_verified"],
        status: json["status"],
        totalRates: json["total_rates"],
        averageRates: json["average_rates"],
        truckType: json["truck_type"] == null
            ? null
            : TruckType.fromJson(json["truck_type"]),
        totalShipments: json["total_shipments"],
        countries: json["countries"] == null
            ? []
            : List<TruckType>.from(
                json["countries"]!.map((x) => TruckType.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "image": image,
        "is_verified": isVerified,
        "status": status,
        "total_rates": totalRates,
        "average_rates": averageRates,
        "truck_type": truckType?.toJson(),
        "total_shipments": totalShipments,
        "countries": countries == null
            ? []
            : List<dynamic>.from(countries!.map((x) => x.toJson())),
      };
}

class TruckType {
  int? id;
  String? name;

  TruckType({
    this.id,
    this.name,
  });

  factory TruckType.fromJson(Map<String, dynamic> json) => TruckType(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
