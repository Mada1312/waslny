class DefaultMainModel {
  String? msg;
  int? status;

  DefaultMainModel({
    this.msg,
    this.status,
  });

  factory DefaultMainModel.fromJson(Map<String, dynamic> json) =>
      DefaultMainModel(
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "status": status,
      };
}
