class DriverProfileMainModel {
  DriverProfileMainModelData? data;
  String? msg;
  int? status;

  DriverProfileMainModel({this.data, this.msg, this.status});

  factory DriverProfileMainModel.fromJson(Map<String, dynamic> json) =>
      DriverProfileMainModel(
        data: json["data"] == null
            ? null
            : DriverProfileMainModelData.fromJson(json["data"]),
        msg: json["msg"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "msg": msg,
    "status": status,
  };
}

class DriverProfileMainModelData {
  int? id;
  String? name;
  String? phone;
  String? status;
  String? image;
  String? frontVehicleLicense;
  String? backVehicleLicense;
  String? drivingLicense;
  String? frontNationalId;
  String? backNationalId;
  int? userType;
  int? isActive;
  String? vehiclePlateNumber;
  String? vehicleModel;
  String? vehicleColor;
  int? gender;
  String? genderName;
  int? isVerified;
  int? trips;
  dynamic avgRate;
  dynamic percentage;
  List<RateModel>? rates;

  DriverProfileMainModelData({
    this.id,
    this.name,
    this.phone,
    this.status,
    this.image,
    this.frontVehicleLicense,
    this.backVehicleLicense,
    this.drivingLicense,
    this.frontNationalId,
    this.backNationalId,
    this.userType,
    this.isActive,
    this.vehiclePlateNumber,
    this.vehicleModel,
    this.vehicleColor,
    this.gender,
    this.genderName,
    this.isVerified,
    this.trips,
    this.avgRate,
    this.percentage,
    this.rates,
  });

  factory DriverProfileMainModelData.fromJson(Map<String, dynamic> json) =>
      DriverProfileMainModelData(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        status: json["status"],
        image: json["image"],
        frontVehicleLicense: json["front_vehicle_license"],
        backVehicleLicense: json["back_vehicle_license"],
        drivingLicense: json["driving_license"],
        frontNationalId: json["front_national_id"],
        backNationalId: json["back_national_id"],
        userType: json["user_type"],
        isActive: json["is_active"],
        vehiclePlateNumber: json["vehicle_plate_number"],
        vehicleModel: json["vehicle_model"],
        vehicleColor: json["vehicle_color"],
        gender: json["gender"],
        genderName: json["gender_name"],
        isVerified: json["is_verified"],
        trips: json["trips"],
        avgRate: json["avg_rate"],
        percentage: json["percentage"],
        rates: json["rates"] == null
            ? []
            : List<RateModel>.from(
                json["rates"]!.map((x) => RateModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "status": status,
    "image": image,
    "front_vehicle_license": frontVehicleLicense,
    "back_vehicle_license": backVehicleLicense,
    "driving_license": drivingLicense,
    "front_national_id": frontNationalId,
    "back_national_id": backNationalId,
    "user_type": userType,
    "is_active": isActive,
    "vehicle_plate_number": vehiclePlateNumber,
    "vehicle_model": vehicleModel,
    "vehicle_color": vehicleColor,
    "gender": gender,
    "gender_name": genderName,
    "is_verified": isVerified,
    "trips": trips,
    "avg_rate": avgRate,
    "percentage": percentage,
    "rates": rates == null
        ? []
        : List<dynamic>.from(rates!.map((x) => x.toJson())),
  };
}

class RateModel {
  int? id;
  String? user;
  String? image;
  String? rate;
  String? comment;
  String? createdAt;

  RateModel({
    this.id,
    this.user,
    this.image,
    this.rate,
    this.comment,
    this.createdAt,
  });

  factory RateModel.fromJson(Map<String, dynamic> json) => RateModel(
    id: json["id"],
    user: json["user"],
    image: json["image"],
    rate: json["rate"],
    comment: json["comment"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user,
    "image": image,
    "rate": rate,
    "comment": comment,
    "created_at": createdAt,
  };
}
