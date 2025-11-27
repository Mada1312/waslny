import 'package:waslny/core/exports.dart';

import 'model/driver_details_model.dart';

class DriverDetailsRepo {
  BaseApiConsumer dio;
  DriverDetailsRepo(this.dio);
  Future<Either<Failure, DriverProfileMainModel>> getDriverById({
    required String driverId,
  }) async {
    try {
      final response = await dio.get(EndPoints.getDriverDetailsUrl + driverId);
      return Right(DriverProfileMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
