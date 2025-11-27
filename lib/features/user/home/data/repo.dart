import 'package:waslny/core/api/base_api_consumer.dart';
import 'package:waslny/core/exports.dart';

import 'models/get_home_model.dart';

class UserHomeRepo {
  BaseApiConsumer api;
  UserHomeRepo(this.api);
  Future<Either<Failure, GetUserHomeModel>> getHome({String type = "0"}) async {
    try {
      final response = await api.get(EndPoints.homeUrl + type);
      return Right(GetUserHomeModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
    Future<Either<Failure, DefaultPostModel>> addRateForDriver({
    required String tripId,
    required double rate,
    required String comment,
  }) async {
    try {
      final response = await api.post(
        EndPoints.addRateUrl,
        body: {
          "trip_id": tripId,
          "rate": rate,
          if (comment.isNotEmpty) "comment": comment,
          "key": "addRate",
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
    Future<Either<Failure, DefaultPostModel>> skipRate({
    required String tripId,
  }) async {
    try {
      final response = await api.post(
        EndPoints.skipRateUrl,
        body: {
          "trip_id": tripId,
         
          "key": "skipRateTrip",
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
