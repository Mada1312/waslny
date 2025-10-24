import 'package:waslny/features/general/auth/data/model/validate_data.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

import '../../../../core/exports.dart';
import '../../../../core/preferences/preferences.dart';

import 'models/main_settings_model.dart';

class ProfileRepo {
  BaseApiConsumer dio;
  ProfileRepo(this.dio);

  //key

  Future<Either<Failure, DefaultPostModel>> contactUs({
    required String name,

    required String message,
  }) async {
    try {
      var response = await dio.post(
        EndPoints.contactUsUrl,
        formDataIsEnabled: true,
        body: {"key": "contactUs", 'title': name, 'body': message},
      );

      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> deleteAccount() async {
    try {
      var response = await dio.post(EndPoints.deleteAccountUrl);

      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> logout() async {
    try {
      var response = await dio.post(
        EndPoints.logoutUrl,
        body: {
          "key": "logout",
          "device_token": await Preferences.instance.getDeviceToken(),
        },
      );

      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, MainSettingModel>> getSettings() async {
    try {
      var response = await dio.get(EndPoints.getSettingsUrl);

      return Right(MainSettingModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, GetUserHomeModel>> getMainFavUserTripsAndServices(
    String type,
  ) async {
    try {
      var response = await dio.get(EndPoints.getFavTripsAndServicesUrl + type);

      return Right(GetUserHomeModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultMainModel>> actionFav(String id) async {
    try {
      var response = await dio.get(EndPoints.changeFavUrl + id);

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultMainModel>> cloneTrip(
    String id, {
    String? scheduleTime,
  }) async {
    try {
      var response = await dio.post(
        EndPoints.cloneTripUrl,
        formDataIsEnabled: true,
        body: {
          "trip_id": id,
          if (scheduleTime != null) "schedule_time": scheduleTime,
        },
      );

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
