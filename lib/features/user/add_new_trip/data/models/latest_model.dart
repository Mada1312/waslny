class GetMainLastestLocation {
  List<GetMainLastestLocationData>? data;
  String? msg;
  int? status;

  GetMainLastestLocation({this.data, this.msg, this.status});

  factory GetMainLastestLocation.fromJson(Map<String, dynamic> json) =>
      GetMainLastestLocation(
        data: json["data"] == null
            ? []
            : List<GetMainLastestLocationData>.from(
                json["data"]!.map(
                  (x) => GetMainLastestLocationData.fromJson(x),
                ),
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

class GetMainLastestLocationData {
  String? from;
  String? fromLat;
  String? fromLong;
  String? to;
  String? toLat;
  String? toLong;
  int? isService;
  int? serviceTo;
  String? serviceToName;
  String? distance;

  GetMainLastestLocationData({
    this.from,
    this.fromLat,
    this.fromLong,
    this.to,
    this.toLat,
    this.toLong,
    this.isService,
    this.serviceTo,
    this.serviceToName,
    this.distance,
  });

  factory GetMainLastestLocationData.fromJson(Map<String, dynamic> json) =>
      GetMainLastestLocationData(
        from: json["from"],
        fromLat: json["from_lat"],
        fromLong: json["from_long"],
        to: json["to"],
        toLat: json["to_lat"],
        toLong: json["to_long"],
        isService: json["is_service"],
        serviceTo: json["service_to"],
        serviceToName: json["service_to_name"],
        distance: json["distance"],
      );

  Map<String, dynamic> toJson() => {
    "from": from,
    "from_lat": fromLat,
    "from_long": fromLong,
    "to": to,
    "to_lat": toLat,
    "to_long": toLong,
    "is_service": isService,
    "service_to": serviceTo,
    "service_to_name": serviceToName,
    "distance": distance,
  };
}
