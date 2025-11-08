import 'dart:io';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';

import 'models/driver_home_model.dart';
import 'package:dio/dio.dart';

class DriverHomeRepo {
  BaseApiConsumer api;
  DriverHomeRepo(this.api);
  Future<Either<Failure, GetDriverHomeModel>> getHome() async {
    try {
      final response = await api.get(EndPoints.driverHomeUrl);
      return Right(GetDriverHomeModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> startTrip({required int id}) async {
    try {
      final response = await api.post(
        EndPoints.driverStartTripUrl,
        body: {"trip_id": id},
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> endTrip({required int id}) async {
    try {
      final response = await api.post(
        EndPoints.driverEndTripUrl,
        body: {"trip_id": id},
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> cancleTrip({
    required int id,
  }) async {
    try {
      final response = await api.post(
        EndPoints.driverCancelTripUrl,
        body: {"trip_id": id},
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
  Future<Either<Failure, DefaultPostModel>> updateTripStatus({
    required int id,
    required TripStep step,
      double? arrivalLat,
      double? arrivalLong,
  }) async {
    try {
      final response = await api.post(
        EndPoints.updateTripStepsUrl,
        body: {
          "trip_id": id,
          "step": step
              .stepValue, // is_user_accept|is_driver_accept|is_driver_arrived|is_user_start_trip|is_driver_start_trip
          "value": 1, // 1,0,
            "arrival_lat" : arrivalLat,
          "arrival_long" : arrivalLong,
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> updateDeliveryProfile({
    File? backNationalId,
    File? frontNationalId,
    File? drivingLicense,
    File? backVehicleLicense,
    File? frontVehicleLicense,
    File? image,
  }) async {
    try {
      var response = await api.post(
        EndPoints.updateDriverDataUrl,
        formDataIsEnabled: true,
        body: {
          if (image != null)
            'image': MultipartFile.fromFileSync(
              image.path,
              filename: image.path.split('/').last,
            ),
          if (backNationalId != null)
            'back_national_id': MultipartFile.fromFileSync(
              backNationalId.path,
              filename: backNationalId.path.split('/').last,
            ),
          if (frontNationalId != null)
            'front_national_id': MultipartFile.fromFileSync(
              frontNationalId.path,
              filename: frontNationalId.path.split('/').last,
            ),
          if (drivingLicense != null)
            'driving_license': MultipartFile.fromFileSync(
              drivingLicense.path,
              filename: drivingLicense.path.split('/').last,
            ),
          if (backVehicleLicense != null)
            'back_vehicle_license': MultipartFile.fromFileSync(
              backVehicleLicense.path,
              filename: backVehicleLicense.path.split('/').last,
            ),
          if (frontVehicleLicense != null)
            'front_vehicle_license': MultipartFile.fromFileSync(
              frontVehicleLicense.path,
              filename: frontVehicleLicense.path.split('/').last,
            ),
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> toggleActive() async {
    try {
      var response = await api.post(EndPoints.toggleStatusUrl);
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
