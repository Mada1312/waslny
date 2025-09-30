import '../../../../user/add_new_shipment/data/models/countries_and_types_model.dart';

class LoginModel {
  LoginModelData? data;
  String? msg;
  int? status;

  LoginModel({
    this.data,
    this.msg,
    this.status,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      data: json['data'] != null
          ? LoginModelData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      msg: json['msg'] as String?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'msg': msg,
      'status': status,
    };
  }

  // CopyWith method for LoginModel
  LoginModel copyWith({
    LoginModelData? data,
    String? msg,
    int? status,
  }) {
    return LoginModel(
      data: data ?? this.data,
      msg: msg ?? this.msg,
      status: status ?? this.status,
    );
  }
}

class LoginModelData {
  int? id;
  String? name;
  int? phone;
  int? userType;
  String? token;
  dynamic image;
  dynamic nationalId;
  dynamic frontDriverCard;
  dynamic backDriverCard;
  dynamic exportCard;
  dynamic address;
  List<GetCountriesAndTruckTypeModelData>? countries;
  GetCountriesAndTruckTypeModelData? truckType;

  LoginModelData({
    this.id,
    this.name,
    this.phone,
    this.userType,
    this.token,
    this.image,
    this.nationalId,
    this.frontDriverCard,
    this.backDriverCard,
    this.exportCard,
    this.address,
    this.countries,
    this.truckType,
  });

  factory LoginModelData.fromJson(Map<String, dynamic> json) {
    return LoginModelData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as int?,
      userType: json['user_type'] as int?,
      token: json['token'] as String?,
      image: json['image'],
      nationalId: json['user_type'] == 0 ? null : json['national_id'],
      frontDriverCard:
          json['user_type'] == 0 ? null : json['front_driver_card'],
      backDriverCard: json['user_type'] == 0 ? null : json['back_driver_card'],
      exportCard: json['user_type'] == 1 ? null : json['export_card'],
      address: json['address'],
      countries: json['countries'] != null
          ? (json['countries'] as List<dynamic>)
              .map((x) => GetCountriesAndTruckTypeModelData.fromJson(
                  x as Map<String, dynamic>))
              .toList()
          : [],
      truckType: json['truck_type'] != null
          ? GetCountriesAndTruckTypeModelData.fromJson(
              json['truck_type'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'user_type': userType,
      'token': token,
      'image': image,
      'national_id': nationalId,
      'front_driver_card': frontDriverCard,
      'back_driver_card': backDriverCard,
      'export_card': exportCard,
      'address': address,
      'countries': countries?.map((x) => x.toJson()).toList() ?? [],
      'truck_type': truckType?.toJson(),
    };
  }

  // CopyWith method for LoginModelData
  LoginModelData copyWith({
    int? id,
    String? name,
    int? phone,
    int? userType,
    String? token,
    dynamic image,
    dynamic nationalId,
    dynamic frontDriverCard,
    dynamic backDriverCard,
    dynamic exportCard,
    dynamic address,
    List<GetCountriesAndTruckTypeModelData>? countries,
    GetCountriesAndTruckTypeModelData? truckType,
  }) {
    return LoginModelData(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      token: token ?? this.token,
      image: image ?? this.image,
      nationalId: nationalId ?? this.nationalId,
      frontDriverCard: frontDriverCard ?? this.frontDriverCard,
      backDriverCard: backDriverCard ?? this.backDriverCard,
      exportCard: exportCard ?? this.exportCard,
      address: address ?? this.address,
      countries: countries ?? this.countries,
      truckType: truckType ?? this.truckType,
    );
  }
}
