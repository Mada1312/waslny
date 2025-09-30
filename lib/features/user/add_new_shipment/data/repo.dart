import '../../../../core/exports.dart';
import '../../../general/auth/data/model/validate_data.dart';
import 'models/countries_and_types_model.dart';

class AddNewShipmentRepo {
  BaseApiConsumer dio;
  AddNewShipmentRepo(this.dio);

  Future<Either<Failure, GetCountriesAndTruckTypeModel>> mainGetData(
      {required String model}) async {
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

  Future<Either<Failure, DefaultMainModel>> addNewShipment({
    required String from,
    required String toCountryId,
    required String truckTypeId,
    String? loadSizeFrom,
    String? loadSizeTo,
    required String goodsType,
    required String shipmentDateTime,
    required String description,
    double? lat,
    double? long
  }) async {
    try {
      var response = await dio
          .post(EndPoints.addNewShipmentUrl, formDataIsEnabled: true, body: {
        "key": "addShipment",
        "from": from,
        "to_country_id": toCountryId,
        "truck_type_id": truckTypeId,
        if (loadSizeFrom != null) "load_size_from": loadSizeFrom,
        if (loadSizeTo != null) "load_size_to": loadSizeTo,
        "goods_type": goodsType,
        "shipment_date_time": shipmentDateTime,
        "description": description,
      if (lat != null) "lat":  lat,
      if (long != null) "long":  long
      });

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DefaultMainModel>> updateShipment({
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
    double? long
  }) async {
    try {
      var response =
          await dio.post(EndPoints.updateShipment + shipmentId, body: {
        "key": "updateShipment",
        "from": from,
        "to_country_id": toCountryId,
        "truck_type_id": truckTypeId,
        if (loadSizeFrom != null) "load_size_from": loadSizeFrom,
        if (loadSizeTo != null) "load_size_to": loadSizeTo,
        "goods_type": goodsType,
        "shipment_date_time": shipmentDateTime,
        "description": description,
          if (lat != null) "lat":  lat,
      if (long != null) "long":  long
      });

      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
