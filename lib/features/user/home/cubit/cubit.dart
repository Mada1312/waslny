import 'package:waslny/core/exports.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

import '../data/repo.dart';
import 'state.dart';

class UserHomeCubit extends Cubit<UserHomeState> {
  UserHomeCubit(this.api) : super(UserHomeInitial());

  UserHomeRepo api;

  GetUserHomeModel? homeModel;
  Future<void> getHome(BuildContext context) async {
    emit(UserHomeLoading());
    final result = await api.getHome();
    result.fold(
      (failure) => emit(UserHomeError()),
      (data) {
        homeModel = data;
        // if (homeModel?.data?.user?.exportCard == null) {
        //   warningDialog(context,
        //       title: 'you_are_didnt_upload_export_card_please_upload_it'.tr(),
        //       onPressedOk: () {
        //     Navigator.pushNamed(context, Routes.editUserProfileRoute);
        //   });
        // }

        emit(UserHomeLoaded());
      },
    );
  }
}
