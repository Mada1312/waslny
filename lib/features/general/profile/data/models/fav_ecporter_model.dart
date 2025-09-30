// To parse this JSON data, do


class MainFavModel {
    List<MainFavModelData>? data;
    String? msg;
    int? status;

    MainFavModel({
        this.data,
        this.msg,
        this.status,
    });

    factory MainFavModel.fromJson(Map<String, dynamic> json) => MainFavModel(
        data: json["data"] == null ? [] : List<MainFavModelData>.from(json["data"]!.map((x) => MainFavModelData.fromJson(x))),
        msg: json["msg"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "msg": msg,
        "status": status,
    };
}

class MainFavModelData {
    int? id;
    String? name;
    int? driverId;
    String? phone;
    String? image;

    MainFavModelData({
        this.id,
        this.name,
        this.driverId,
        this.phone,
        this.image,
    });

    factory MainFavModelData.fromJson(Map<String, dynamic> json) => MainFavModelData(
        id: json["id"],
        name: json["name"],
        driverId: json["driver_id"],
        phone: json["phone"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "driver_id": driverId,
        "phone": phone,
        "image": image,
    };
}
