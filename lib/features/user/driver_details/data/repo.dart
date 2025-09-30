import 'package:waslny/core/exports.dart';

import 'model/driver_details_model.dart';

class DriverDetailsRepo {
  BaseApiConsumer dio;
  DriverDetailsRepo(this.dio);
  Future<Either<Failure, DriverDetailsModel>> getDriverById(
      {required String driverId}) async {
    try {
      final response = await dio.get(
        EndPoints.getDriverDetailsUrl + driverId,
      );
      return Right(DriverDetailsModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
