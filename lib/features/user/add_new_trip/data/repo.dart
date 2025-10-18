import '../../../../core/exports.dart';
import '../../../general/auth/data/model/validate_data.dart';
import 'models/countries_and_types_model.dart';

class AddNewTripRepo {
  BaseApiConsumer dio;
  AddNewTripRepo(this.dio);

  Future<Either<Failure, GetCountriesAndTruckTypeModel>> mainGetData({
    required String model,
  }) async {
    try {
      var response = await dio.get(
        EndPoints.mainGetDataUrl,
        queryParameters: {"model": model},
      );

      return Right(GetCountriesAndTruckTypeModel.fromJson(response));
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
    double? toLong,
    required String description,
    required String gender,
    required String vehicleType,

    bool? isSchedule = false,

    bool? isService = false,
    String? scheduleTime,
    String? serviceTo,
  }) async {
    try {
      var response = await dio.post(
        EndPoints.addNewTripUrl,
        formDataIsEnabled: true,
        body: {
          "key": "addTrip",
          "from": from,
          if (fromLat != null) "from_lat": fromLat,
          if (fromLong != null) "from_long": fromLong,
          "to": to,
          if (toLat != null) "to_lat": toLat,
          if (toLong != null) "to_long": toLong,

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

  Future<Either<Failure, DefaultMainModel>> updateTrip({
    required String from,
    required String toCountryId,
    required String truckTypeId,
    String? loadSizeFrom,
    String? loadSizeTo,
    required String goodsType,
    required String shipmentDateTime,
    required String description,
    required String shipmentId,
    double? lat,
    double? long,
  }) async {
    try {
      var response = await dio.post(
        EndPoints.updateTrip + shipmentId,
        body: {
          "key": "updateShipment",
          "from": from,
          "to_country_id": toCountryId,
          "truck_type_id": truckTypeId,
          if (loadSizeFrom != null) "load_size_from": loadSizeFrom,
          if (loadSizeTo != null) "load_size_to": loadSizeTo,
          "goods_type": goodsType,
          "shipment_date_time": shipmentDateTime,
          "description": description,
          if (lat != null) "lat": lat,
          if (long != null) "long": long,
        },
      );

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
