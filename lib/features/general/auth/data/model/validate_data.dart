class DefaultMainModel {
  String? msg;
  dynamic data;
  int? status;

  DefaultMainModel({this.msg, this.status, this.data});

  factory DefaultMainModel.fromJson(Map<String, dynamic> json) =>
      DefaultMainModel(
        msg: json["msg"].toString(),
        status: json["status"],

        data: json["data"],
      );

  Map<String, dynamic> toJson() => {"msg": msg, "status": status, "data": data};
}
