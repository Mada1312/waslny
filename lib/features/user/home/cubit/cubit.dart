import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

import '../data/repo.dart';
import 'state.dart';

class UserHomeCubit extends Cubit<UserHomeState> {
  UserHomeCubit(this.api) : super(UserHomeInitial());

  UserHomeRepo api;
  ServicesType? serviceType = ServicesType.trips;
  GetUserHomeModel? homeModel;
  Future<void> getHome(BuildContext context) async {
    emit(UserHomeLoading());
    final result = await api.getHome(
      type: serviceType?.name == ServicesType.services.name ? '1' : '0',
    );
    log('PPPP trips ${serviceType?.name == ServicesType.trips.name}');
    log('PPPP services ${serviceType?.name == ServicesType.services.name}');
    result.fold((failure) => emit(UserHomeError()), (data) {
      homeModel = data;
      // if (homeModel?.data?.user?.exportCard == null) {
      //   warningDialog(context,
      //       title: 'you_are_didnt_upload_export_card_please_upload_it'.tr(),
      //       onPressedOk: () {
      //     Navigator.pushNamed(context, Routes.editUserProfileRoute);
      //   });
      // }

      emit(UserHomeLoaded());
    });
  }
}
