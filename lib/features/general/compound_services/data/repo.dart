import 'package:waslny/core/exports.dart';

import 'models/get_compound_model.dart';

class CompoundServicesRepo {
  BaseApiConsumer api;
  CompoundServicesRepo(this.api);

  Future<Either<Failure, GetCompoundServicesModel>> getCompoundServices(
    String? search,
  ) async {
    try {
      var response = await api.get(EndPoints.getproductsUrl + (search ?? ''));
      return Right(GetCompoundServicesModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
