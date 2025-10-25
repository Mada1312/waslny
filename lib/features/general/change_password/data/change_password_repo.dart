import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/auth/data/model/validate_data.dart';

class ChangePasswordRepo {
  final BaseApiConsumer api;

  ChangePasswordRepo(this.api);

  Future<Either<Failure, DefaultMainModel>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await api.post(
        EndPoints.updatePassword,
        body: {"old_password": oldPassword, "password": newPassword},
      );
      return Right(DefaultMainModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
