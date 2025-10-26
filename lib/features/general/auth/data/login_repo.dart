import 'dart:developer';
import 'dart:io';

import 'package:waslny/core/preferences/preferences.dart';
import 'package:waslny/features/user/add_new_trip/data/models/countries_and_types_model.dart';

import 'package:dio/dio.dart';

import '../../../../core/exports.dart';
import 'model/validate_data.dart';

class LoginRepo {
  BaseApiConsumer dio;
  LoginRepo(this.dio);

  Future<Either<Failure, LoginModel>> login(
    String phone,
    String password, {
    required bool isDriver,
  }) async {
    try {
      var response = await dio.post(
        EndPoints.loginUrl,
        options: Options(headers: {}),
        formDataIsEnabled: true,
        body: {
          "key": "login",
          'phone': phone,
          "device_type": Platform.isAndroid ? '1' : '0',
          "device_token": await Preferences.instance.getDeviceToken(),
          // 'user_type': isDriver ? '1' : '0',
          'password': password,
        },
      );

      return Right(LoginModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  //! register step one validate data then register
  Future<Either<Failure, DefaultMainModel>> validateData({
    required String phone,
    required String password,
    required String name,
    String? gender,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleNumber,
    String? vehicleColor,
    required bool isDriver,
  }) async {
    try {
      var response = await dio.post(
        EndPoints.validateDataUrl,
        options: Options(headers: {}),
        formDataIsEnabled: true,
        body: {
          "key": "validateData",
          'phone': phone,
          'name': name,
          'password': password,
          'user_type': isDriver ? '1' : '0',
          if (isDriver) 'vehicle_type': vehicleType,
          if (isDriver) 'gender': gender,
          if (isDriver) 'vehicle_color': vehicleColor,
          if (isDriver) 'vehicle_plate_number': vehicleNumber,
          if (isDriver) 'vehicle_model': vehicleModel,
        },
      );
      log('validateData Response: ${response.toString()}');

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, LoginModel>> register({
    required String phone,
    required String password,
    required String name,
    // required String otp,
    required bool isDriver,
    required String gender,
    required String vehicleType,
    required String vehicleModel,
    required String vehicleNumber,
    required String vehicleColor,
  }) async {
    try {
      var response = await dio.post(
        EndPoints.registerUrl,
        options: Options(headers: {}),
        formDataIsEnabled: true,
        body: {
          "key": "register",
          "device_type": Platform.isAndroid ? '1' : '0',
          "device_token": await Preferences.instance.getDeviceToken(),
          'phone': phone,
          'name': name,
          'password': password,
          'user_type': isDriver ? '1' : '0',
          // "otp": otp,

          if (isDriver) 'vehicle_type': vehicleType,
          if (isDriver) 'gender': gender,
          if (isDriver) 'vehicle_color': vehicleColor,
          if (isDriver) 'vehicle_plate_number': vehicleNumber,
          if (isDriver) 'vehicle_model': vehicleModel,
        },
      );

      return Right(LoginModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
  //!

  Future<Either<Failure, DefaultMainModel>> forgetPassword(String phone) async {
    try {
      log('phone ====>> $phone');
      var response = await dio.post(
        EndPoints.forgetPasswordUrl,
        formDataIsEnabled: true,
        body: {'key': 'forgetPassword', "phone": phone},
      );

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, LoginModel>> resetPassword(
    String phone,
    String password,
    String otp,
  ) async {
    try {
      String? token = await Preferences.instance.getDeviceToken();
      var response = await dio.post(
        EndPoints.resetPasswordUrl,
        formDataIsEnabled: true,
        body: {
          'key': "resetPassword",
          "device_type": Platform.isAndroid ? '1' : '0',
          "device_token": token,
          'phone': phone,
          "password": password,
          "otp": otp,
        },
      );

      return Right(LoginModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, LoginModel>> authData() async {
    try {
      var response = await dio.get(EndPoints.authDatatUrl);

      return Right(LoginModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> changeLanguage() async {
    String lang = await Preferences.instance.getSavedLang();

    log("lang =  $lang");

    try {
      var response = await dio.post(
        EndPoints.changeLanguageUrl,
        body: {'language': lang},
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, LoginModel>> updateUserProfile({
    String? name,
    String? address,
    File? image,
  }) async {
    try {
      var response = await dio.post(
        EndPoints.updateUserProfiletUrl,
        formDataIsEnabled: true,
        body: {
          "key": "updateProfile",
          'name': name,
          'address': address,
          if (image != null)
            'image': MultipartFile.fromFileSync(
              image.path,
              filename: image.path.split('/').last,
            ),
        },
      );

      return Right(LoginModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, LoginModel>> updateDeliveryProfile({
    String? name,
    
    File? image,
   
  }) async {
    try {
      var response = await dio.post(
        EndPoints.updateDeliveryprofiletUrl,
        formDataIsEnabled: true,
        body: {
          'name': name,
      
          if (image != null)
            'image': MultipartFile.fromFileSync(
              image.path,
              filename: image.path.split('/').last,
            ),
         
        },
      );

      return Right(LoginModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
