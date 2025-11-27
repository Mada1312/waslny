import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/trips/data/models/get_trips_model.dart';

import 'models/shipment_details_model.dart';

class DriverShipmentsRepo {
  BaseApiConsumer api;
  DriverShipmentsRepo(this.api);
  Future<Either<Failure, GetDriverTripsModel>> getDriverScheduleTrips() async {
    try {
      final response = await api.get(EndPoints.driverScheduleTripsUrl);
      return Right(GetDriverTripsModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

 Future<Either<Failure, DefaultPostModel>> cancleTrip({
    required int id,
  }) async {
    try {
      final response = await api.post(
        EndPoints.driverCancelTripUrl,
        body: {"trip_id": id},
      );
      return Right(DefaultPostModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

}
