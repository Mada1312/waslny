import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/shipments/data/models/get_shipments_model.dart';

import 'models/shipment_details_model.dart';

class DriverShipmentsRepo {
  BaseApiConsumer api;
  DriverShipmentsRepo(this.api);
  Future<Either<Failure, GetDriverShipmentsModel>> getDriverShipments() async {
    try {
      final response = await api.get(
        EndPoints.driverShipmentsUrl,
      );
      return Right(GetDriverShipmentsModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, GetDriverShipmentDetailsModel>>
      getDriverShipmentDetails({required String id}) async {
    try {
      final response = await api.get(
        EndPoints.driverShipmnetDetailsUrl + id,
      );
      return Right(GetDriverShipmentDetailsModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> requestShipment(
      {required String id}) async {
    try {
      final response = await api.get(
        EndPoints.driverRequestShipmentUrl + id,
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> cancelRequestShipment(
      {required String id}) async {
    try {
      final response = await api.get(
        EndPoints.driverCancelRequestShipmentUrl + id,
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> addRateForUser(
      {required String shipmentId,
      required double rate,
      required String userId,
      required String comment}) async {
    try {
      final response = await api.post(
        EndPoints.addRateUrl,
        body: {
          "shipment_id": shipmentId,
          "rate": rate,
          if (comment.isNotEmpty) "comment": comment,
          "is_driver": "1",
          "participant_id": userId,
          "key": "addRate"
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
