class GetCountriesAndTruckTypeModel {
  List<GetCountriesAndTruckTypeModelData>? data;
  String? msg;
  int? status;

  GetCountriesAndTruckTypeModel({
    this.data,
    this.msg,
    this.status,
  });

  factory GetCountriesAndTruckTypeModel.fromJson(Map<String, dynamic> json) =>
      GetCountriesAndTruckTypeModel(
        data: json["data"] == null
            ? []
            : List<GetCountriesAndTruckTypeModelData>.from(json["data"]!
                .map((x) => GetCountriesAndTruckTypeModelData.fromJson(x))),
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

class GetCountriesAndTruckTypeModelData {
  int? id;
  String? name;

  GetCountriesAndTruckTypeModelData({
    this.id,
    this.name,
  });

  factory GetCountriesAndTruckTypeModelData.fromJson(
          Map<String, dynamic> json) =>
      GetCountriesAndTruckTypeModelData(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
