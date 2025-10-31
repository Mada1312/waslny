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
  Future<void> getHome(BuildContext context, {bool? isVerify = false}) async {
    emit(UserHomeLoading());
    final result = await api.getHome(
      type: serviceType?.name == ServicesType.services.name ? '1' : '0',
    );
    log('PPPP trips ${serviceType?.name == ServicesType.trips.name}');
    log('PPPP services ${serviceType?.name == ServicesType.services.name}');
    result.fold((failure) => emit(UserHomeError()), (data) {
      homeModel = data;
      // log('888888888888 ${data.data?.isWebhookVerified}');
      // if (!(isVerify == true) || data.data?.isWebhookVerified == 1) {
      //   //! false X false
      //   if (data.data?.isWebhookVerified == 0) {
      //     Navigator.pushReplacementNamed(
      //       context,
      //       Routes.notVerifiedUserRoute,
      //       arguments: false,
      //     );
      //   }
      //   if (isVerify == true) {
      //     Navigator.pushReplacementNamed(
      //       context,
      //       Routes.mainRoute,
      //       arguments: false,
      //     );
      //   }

      // }

      emit(UserHomeLoaded());
    });
  }
}
