class MainSettingModel {
  MainSettingModelData? data;
  String? msg;
  int? status;

  MainSettingModel({
    this.data,
    this.msg,
    this.status,
  });

  factory MainSettingModel.fromJson(Map<String, dynamic> json) =>
      MainSettingModel(
        data: json["data"] == null
            ? null
            : MainSettingModelData.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "msg": msg,
        "status": status,
      };
}

class MainSettingModelData {
  String? appName;
  String? logo;
  String? favIcon;
  String? loader;
  String? appMaintenance;
  String? developmentMode;
  String? androidAppVersion;
  String? iosAppVersion;
  String? liveLocationHours;
  String? privacy;
  String? whatsappNumber;
  String? facebookLink;
  String? instaLink;

  MainSettingModelData({
    this.appName,
    this.logo,
    this.favIcon,
    this.loader,
    this.appMaintenance,
    this.facebookLink,
    this.developmentMode,
    this.androidAppVersion,
    this.iosAppVersion,
    this.liveLocationHours,
    this.whatsappNumber,
    this.privacy,
    this.instaLink,
  });

  factory MainSettingModelData.fromJson(Map<String, dynamic> json) =>
      MainSettingModelData(
        appName: json["app_name"],
        logo: json["logo"],
        favIcon: json["fav_icon"],
        loader: json["loader"],
        facebookLink: json["facebook_link"],
        instaLink: json["insta_link"],
        appMaintenance: json["app_maintenance"],
        developmentMode: json["development_mode"],
        androidAppVersion: json["android_app_version"],
        whatsappNumber: json["whatsapp_number"],
        iosAppVersion: json["ios_app_version"],
        liveLocationHours: json["live_location_hours"],
        privacy: json["privacy"],
      );

  Map<String, dynamic> toJson() => {
        "app_name": appName,
        "facebook_link": facebookLink,
        "insta_link": instaLink,
        "logo": logo,
        "fav_icon": favIcon,
        "loader": loader,
        "whatsapp_number": whatsappNumber,
        "app_maintenance": appMaintenance,
        "development_mode": developmentMode,
        "android_app_version": androidAppVersion,
        "ios_app_version": iosAppVersion,
        "live_location_hours": liveLocationHours,
        "privacy": privacy,
      };
}
