import 'package:waslny/core/exports.dart';
import 'package:waslny/core/preferences/preferences.dart';
import 'package:waslny/features/general/auth/data/model/validate_data.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/trip_and_services/data/models/get_shipments.dart';

import 'models/shipment_details.dart';

class UserShipmentsRepo {
  BaseApiConsumer api;
  UserShipmentsRepo(this.api);
  //! Trip and service
  Future<Either<Failure, DefaultMainModel>> changeFavOfTripAndService(
    String id,
  ) async {
    try {
      final response = await api.get(EndPoints.changeFavUrl + id);
      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  //!

  // Future<Either<Failure, GetShipmentsModel>> getShipments({
  //   required String status,
  // }) async {
  //   try {
  //     final userModel = await Preferences.instance.getUserModel();
  //     String? userId = userModel.data?.id.toString();

  //     final response = await api.get(
  //       EndPoints.mainGetDataUrl,
  //       queryParameters: {
  //         "model": "Shipment",
  //         "where[0]": "status,$status",
  //         if (userId != null) "where[1]": "user_id,$userId",
  //       },
  //     );
  //     return Right(GetShipmentsModel.fromJson(response));
  //   } on ServerException {
  //     return Left(ServerFailure());
  //   }
  // }

  Future<Either<Failure, GetUserHomeModel>> getCompletedTripsAndServices({
    required String type,
  }) async {
    try {
      final response = await api.get('${EndPoints.getMyTrips}$type');
      return Right(GetUserHomeModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultMainModel>> cancelTrip({
    required String tripId,
  }) async {
    try {
      final response = await api.post(
        EndPoints.cancelTrip,
        body: {"trip_id": tripId},
      );
      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, GetUserShipmentDetailsModel>> getShipmentDetails({
    required String id,
  }) async {
    try {
      final response = await api.get(EndPoints.shipmentDetailsUrl + id);
      return Right(GetUserShipmentDetailsModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> completeShipment({
    required String id,
  }) async {
    try {
      final response = await api.get(EndPoints.userCompleteShipmentUrl + id);
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> deleteShipment({
    required String id,
  }) async {
    try {
      final response = await api.get(EndPoints.deleteShipmentUrl + id);
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> updateIsNotify({
    required String id,
  }) async {
    try {
      final response = await api.post(
        EndPoints.updateIsNotifyUrl,
        body: {"shipment_id": id, "key": "isNotify"},
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> assignDriver({
    required String shipmentId,
    required String driverId,
  }) async {
    try {
      final response = await api.post(
        EndPoints.assignDriverUrl,
        body: {
          "shipment_id": shipmentId,
          "driver_id": driverId,
          "key": "assignDriver",
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> updateShipmentStatus({
    required String shipmentId,
    required String status,
    double? lat,
    double? long,
  }) async {
    try {
      final response = await api.post(
        EndPoints.updateShipmentStatusUrl,
        body: {
          "shipment_id": shipmentId,
          "status": status,
          if (lat != null) "lat": lat,
          if (long != null) "long": long,
          "key": "updateShipmentStatus",
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultPostModel>> addRateForDriver({
    required String shipmentId,
    required double rate,
    required String driverrId,
    required String comment,
  }) async {
    try {
      final response = await api.post(
        EndPoints.addRateUrl,
        body: {
          "shipment_id": shipmentId,
          "rate": rate,
          if (comment.isNotEmpty) "comment": comment,
          "is_driver": "0",
          "participant_id": driverrId,
          "key": "addRate",
        },
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
