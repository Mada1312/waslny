import 'dart:async';
import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/background_services.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/repo.dart';
import 'state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit(this.api) : super(DriverHomeInitial()) {
    // _checkServiceStatus();
    // _listenToServiceUpdates();
  }

  DriverHomeRepo api;

  GetDriverHomeModel? homeModel;
  Future<void> getDriverHomeData(BuildContext context) async {
    emit(DriverHomeLoading());
    try {
      final result = await api.getHome();
      result.fold((failure) => emit(DriverHomeError()), (data) {
        homeModel = data;

        emit(DriverHomeLoaded());
        // if (homeModel?.data?.hasShipment == false) {
        //   stopLocationService();
        // } else {
        //   homeModel?.data?.currentDriverShipment?.status == 2
        //       //  &&
        //       //         homeModel?.data?.currentDriverShipment?.driverIsDeliverd ==
        //       //             0
        //       ? isServiceRunning
        //           ? null
        //           : startLocationService(context: context)
        //       : stopLocationService();
        // }
      });
    } catch (e) {
      log("Error in getDriverHomeData: $e");
      emit(DriverHomeError());
    }
  }

  Future<void> completeShipment({
    required String shipmentId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(CompleteShipmentLoadingState());
    try {
      final response = await api.completeShipment(id: shipmentId);
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(CompleteShipmentErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(CompleteShipmentSuccessState());
            // stopLocationService();
            successGetBar(response.msg ?? "Shipment completed successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to complete shipment");
          }
        },
      );
    } catch (e) {
      log("Error in completeShipment: $e");
      emit(CompleteShipmentErrorState());
    }
  }

  Future<void> cancleCurrentShipment({
    required String shipmentId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(CancelShipmentLoadingState());
    try {
      final response = await api.cancleCurrentShipment(id: shipmentId);
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(CancelShipmentErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(CancelShipmentSuccessState());
            successGetBar(response.msg ?? "Shipment cancelled successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to cancel shipment");
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(CancelShipmentErrorState());
    }
  }

  // wasalnyyy  */

  bool isOnline = false;

  changeOnlineStatus() {
    isOnline = !isOnline;
    emit(ChangeOnlineStatusState());
  }

  // 0 first time 1 has trip
  int step = 0;

  changeStep() {
    if (step == 1)
      step = 0;
    else
      step++;
    emit(ChangeOnlineStatusState());
  }

  // StreamSubscription? _locationSub;

  // @override
  // Future<void> close() {
  //   _locationSub?.cancel();
  //   return super.close();
  // }
}
