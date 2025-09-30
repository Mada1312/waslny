// To parse this JSON data, do
//
//     final mainTutorialVideoModel = mainTutorialVideoModelFromJson(jsonString);

import 'dart:convert';

MainTutorialVideoModel mainTutorialVideoModelFromJson(String str) =>
    MainTutorialVideoModel.fromJson(json.decode(str));

String mainTutorialVideoModelToJson(MainTutorialVideoModel data) =>
    json.encode(data.toJson());

class MainTutorialVideoModel {
  List<MainTutorialVideoModelData>? data;
  String? msg;
  int? status;

  MainTutorialVideoModel({
    this.data,
    this.msg,
    this.status,
  });

  factory MainTutorialVideoModel.fromJson(Map<String, dynamic> json) =>
      MainTutorialVideoModel(
        data: json["data"] == null
            ? []
            : List<MainTutorialVideoModelData>.from(json["data"]!
                .map((x) => MainTutorialVideoModelData.fromJson(x))),
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

class MainTutorialVideoModelData {
  int? id;
  String? title;
  String? description;
  int? type;
  String? typeName;
  String? video;
  String? image;

  MainTutorialVideoModelData({
    this.id,
    this.title,
    this.description,
    this.type,
    this.typeName,
    this.video,
    this.image,
  });

  factory MainTutorialVideoModelData.fromJson(Map<String, dynamic> json) =>
      MainTutorialVideoModelData(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        type: json["type"],
        typeName: json["type_name"],
        video: json["video"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "type": type,
        "type_name": typeName,
        "video": video,
        "image": image,
      };
}
