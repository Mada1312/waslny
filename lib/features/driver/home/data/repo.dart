import 'package:waslny/core/exports.dart';

import 'models/driver_home_model.dart';

class DriverHomeRepo {
  BaseApiConsumer api;
  DriverHomeRepo(this.api);
  Future<Either<Failure, GetDriverHomeModel>> getHome() async {
    try {
      final response = await api.get(
        EndPoints.driverHomeUrl,
      );
      return Right(GetDriverHomeModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> completeShipment(
      {required String id}) async {
    try {
      final response = await api.get(
        EndPoints.driverCompleteShipmentUrl + id,
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> cancleCurrentShipment(
      {required String id}) async {
    try {
      final response = await api.get(
        EndPoints.driverCancelCurrentShipmentUrl + id,
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> addShipmemntLocation(
      {required String id}) async {
    try {
      final response = await api.post(
        EndPoints.addShipmentLocationUrl,
        body: {
          "shipment_id": id,
          "location": "test location",
          "key": "addShipmentLocation"
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
