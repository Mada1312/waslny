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
}
