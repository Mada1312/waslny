class VerifyCodeRequestModel {
  dynamic data;
  String? msg;
  int? status;

  VerifyCodeRequestModel({
    this.data,
    this.msg,
    this.status,
  });

  factory VerifyCodeRequestModel.fromJson(Map<String, dynamic> json) =>
      VerifyCodeRequestModel(
        data: json["data"],
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "msg": msg,
        "status": status,
      };
}
