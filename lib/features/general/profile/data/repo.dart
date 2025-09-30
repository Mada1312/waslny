import 'package:waslny/features/general/auth/data/model/validate_data.dart';

import '../../../../core/exports.dart';
import '../../../../core/preferences/preferences.dart';
import 'models/fav_ecporter_model.dart';
import 'models/main_settings_model.dart';

class ProfileRepo {
  BaseApiConsumer dio;
  ProfileRepo(this.dio);

  //key

  Future<Either<Failure, DefaultPostModel>> contactUs({
    required String address,
    required String subject,
    required String message,
  }) async {
    try {
      var response = await dio.post(EndPoints.contactUsUrl,
          formDataIsEnabled: true,
          body: {
            "key": "contactUs",
            'address': address,
            'title': subject,
            'body': message
          });

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
      var response = await dio.post(EndPoints.logoutUrl, body: {
        "key": "logout",
        "device_token": await Preferences.instance.getDeviceToken()
      });

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

  Future<Either<Failure, MainFavModel>> getMainFavUserDriver() async {
    try {
      final userModel = await Preferences.instance.getUserModel();
      var response = await dio.get(EndPoints.mainGetDataUrl, queryParameters: {
        "model": "Fav",
        // "where[0]": "user_id,105"
        "where[0]": "user_id,${userModel.data!.id.toString()}"
      });

      return Right(MainFavModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultMainModel>> actionFav(String driverId) async {
    try {
      var response = await dio.post(EndPoints.actionFavUrl,
          formDataIsEnabled: true,
          body: {"key": "actionFav", "driver_id": driverId});

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
