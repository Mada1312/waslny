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
      result.fold(
        (failure) => emit(DriverHomeError()),
        (data) {
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
        },
      );
    } catch (e) {
      log("Error in getDriverHomeData: $e");
      emit(DriverHomeError());
    }
  }

  Future<void> completeShipment(
      {required String shipmentId, required BuildContext context}) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(CompleteShipmentLoadingState());
    try {
      final response = await api.completeShipment(
        id: shipmentId,
      );
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
            successGetBar(
              response.msg ?? "Shipment completed successfully",
            );
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            getDriverHomeData(context);
          } else {
            errorGetBar(
              response.msg ?? "Failed to complete shipment",
            );
          }
        },
      );
    } catch (e) {
      log("Error in completeShipment: $e");
      emit(CompleteShipmentErrorState());
    }
  }

  Future<void> cancleCurrentShipment(
      {required String shipmentId, required BuildContext context}) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(CancelShipmentLoadingState());
    try {
      final response = await api.cancleCurrentShipment(
        id: shipmentId,
      );
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(CancelShipmentErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(CancelShipmentSuccessState());
            successGetBar(
              response.msg ?? "Shipment cancelled successfully",
            );
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            getDriverHomeData(context);
          } else {
            errorGetBar(
              response.msg ?? "Failed to cancel shipment",
            );
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(CancelShipmentErrorState());
    }
  }

  // Future<void> addShipmemntLocation(
  //     {required String shipmentId, required BuildContext context}) async {
  //   // AppWidget.createProgressDialog(context, msg: "...");
  //   emit(CompleteShipmentLoadingState());
  //   try {
  //     final response = await api.addShipmemntLocation(
  //       id: shipmentId,
  //     );
  //     response.fold(
  //       (failure) {
  //         // Navigator.pop(context); // Close the progress dialog
  //         emit(CompleteShipmentErrorState());
  //       },
  //       (response) {
  //         // Navigator.pop(context); // Close the progress dialog
  //         if (response.status == 200 || response.status == 201) {
  //           emit(CompleteShipmentSuccessState());
  //           successGetBar(
  //             response.msg ?? "Shipment completed successfully",
  //           );
  //           getDriverHomeData();
  //           // Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
  //         } else {
  //           errorGetBar(
  //             response.msg ?? "Failed to complete shipment",
  //           );
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     log("Error in completeShipment: $e");
  //     emit(CompleteShipmentErrorState());
  //   }
  // }

// //  BackGroundDervice
//   bool isServiceRunning = false;
//   String statusMessage = "Service stopped";
//   String lastUpdate = "Never";

//   StreamSubscription? _locationSub;

//   void _listenToServiceUpdates() {
//     _locationSub = BackgroundLocationService.onLocationUpdate.listen((data) {
//       lastUpdate = data['timestamp'] ?? 'Unknown';
//       statusMessage = isServiceRunning
//           ? "Service running - Last update: $lastUpdate"
//           : "Service stopped";

//       emit(BackgroundLocationUpdated());
//     });
//   }

  // Future<void> _checkServiceStatus() async {
  //   isServiceRunning = await BackgroundLocationService.isServiceRunning();
  //   statusMessage = isServiceRunning ? "Service running" : "Service stopped";
  //   emit(BackgroundLocationUpdated());
  // }

  // Future<void> startLocationService({required BuildContext context}) async {
  //   statusMessage = "Requesting permissions...";
  //   emit(BackgroundLocationUpdated());

  //   bool hasPermissions = await _requestPermissions(context: context);
  //   if (!hasPermissions) {
  //     statusMessage = "permission_required".tr();
  //     emit(BackgroundLocationUpdated());
  //     return;
  //   }

  //   statusMessage = "Starting service...";
  //   emit(BackgroundLocationUpdated());

  //   try {
  //     bool started = await BackgroundLocationService.startService();
  //     if (started) {
  //       isServiceRunning = true;
  //       statusMessage = "Service started - Updates every 2 minutes";
  //       // successGetBar("tracking_started".tr());
  //     } else {
  //       statusMessage = "Failed to start service";
  //       errorGetBar("failed_to_start_tracking".tr());
  //     }
  //   } catch (e) {
  //     statusMessage = "Failed to start service: $e";
  //     errorGetBar("failed_to_start_tracking".tr());
  //   }

  //   emit(BackgroundLocationUpdated());
  // }

  // Future<void> stopLocationService() async {
  //   statusMessage = "Stopping service...";
  //   emit(BackgroundLocationUpdated());

  //   try {
  //     bool stopped = await BackgroundLocationService.stopService();
  //     if (stopped) {
  //       isServiceRunning = false;
  //       statusMessage = "Service stopped";
  //       lastUpdate = "Never";
  //       // successGetBar("tracking_stopped".tr());
  //     } else {
  //       statusMessage = "Failed to stop service";
  //       errorGetBar("failed_to_stop_tracking".tr());
  //     }
  //   } catch (e) {
  //     statusMessage = "Failed to stop service: $e";
  //     errorGetBar("failed_to_stop_tracking".tr());
  //   }

  //   emit(BackgroundLocationUpdated());
  // }

  // Future<bool> _requestPermissions({required BuildContext context}) async {
  //   Map<Permission, PermissionStatus> permissions = await [
  //     Permission.location,
  //     Permission.locationAlways,
  //     Permission.notification,
  //   ].request();

  //   if (permissions[Permission.location]?.isDenied ?? true) {
  //     _showPermissionDialog("foreground_permission_required".tr(), context);
  //     return false;
  //   }
  //   if (permissions[Permission.locationAlways]?.isDenied ?? true) {
  //     _showPermissionDialog("background_permission_required".tr(), context);
  //     return false;
  //   }

  //   return true;
  // }

  /// عرض رسالة للمستخدم

  /// عرض dialog للإذونات
  // void _showPermissionDialog(String message, BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("permission_required".tr()),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             child: Text("cancel".tr()),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: Text("open_settings".tr()),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               openAppSettings();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // @override
  // Future<void> close() {
  //   _locationSub?.cancel();
  //   return super.close();
  // }
}
