import 'package:waslny/core/exports.dart';

import 'model/driver_details_model.dart';

class DriverProfileRepo {
  BaseApiConsumer dio;
  DriverProfileRepo(this.dio);
  Future<Either<Failure, DriverProfileMainModel>> getDriverById() async {
    try {
      final response = await dio.get(EndPoints.getMyDriverDetailsUrl);
      return Right(DriverProfileMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
