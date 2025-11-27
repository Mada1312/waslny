import 'dart:developer';

import 'package:waslny/features/user/add_new_trip/data/models/latest_model.dart';

import '../../../../core/exports.dart';
import '../../../general/auth/data/model/validate_data.dart';

class AddNewTripRepo {
  BaseApiConsumer dio;
  AddNewTripRepo(this.dio);

  Future<Either<Failure, GetMainLastestLocation>> gettMainLastestLocation(
    bool isService,
  ) async {
    try {
      var response = await dio.get(
        EndPoints.getLastAddressesUrl + (isService == true ? "1" : "0"),
      );

      return Right(GetMainLastestLocation.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultMainModel>> addNewTrip({
    required String from,
    required String to,
    double? fromLat,
    double? fromLong,
    double? toLat,
    num? distance,
    double? toLong,
    required String description,
    required String gender,
    required String vehicleType,
    bool? isSchedule = false,
    bool? isService = false,
    String? scheduleTime,
    String? serviceTo,
  }) async {
    log('distance ${distance}');
    try {
      var response = await dio.post(
        EndPoints.addNewTripUrl,
        formDataIsEnabled: true,
        body: {
          "key": "addTrip",
          "from": from,
          if (isService == false && distance != null)
            "distance": (distance / 1000),
          if (fromLat != null) "from_lat": fromLat,
          if (fromLong != null) "from_long": fromLong,
          if (isService == false) "to": to,
          if (toLat != null && isService == false) "to_lat": toLat,
          if (toLong != null && isService == false) "to_long": toLong,

          "prefer_driver_gender": gender,
          "vehicle_type": vehicleType,
          "description": description,

          "type": isSchedule == true ? "1" : "0",
          if (isSchedule == true) "schedule_time": scheduleTime,

          "is_service": isService == true ? "1" : "0",
          if (isService == true) "service_to": serviceTo,
        },
      );

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
