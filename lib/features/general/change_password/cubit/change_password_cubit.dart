import 'package:waslny/core/exports.dart';

import '../data/change_password_repo.dart';

import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this.api) : super(BursaInitial());

  final ChangePasswordRepo api;

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(LoadingChangePasswordState());
    final res = await api.updatePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    res.fold((l) => emit(FailureChangePasswordState()), (r) {
      if (r.status == 200) {
        successGetBar(r.msg);
        emit(SuccessChangePasswordState());
      } else {
        emit(FailureChangePasswordState());
      }
    });
  }
}
