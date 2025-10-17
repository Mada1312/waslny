import 'dart:developer';
import 'dart:io';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/shipments/data/models/get_shipments.dart';
import 'package:waslny/features/user/shipments/data/models/shipment_details.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../data/repo.dart';
import 'state.dart';

enum ShipmentsStatusEnum { newShipments, pending, loaded, delivered }

class UserShipmentsCubit extends Cubit<UserShipmentsState> {
  UserShipmentsCubit(this.api) : super(ShipmentsInitial());

  UserShipmentsRepo api;

  ShipmentsStatusEnum selectedStatus = ShipmentsStatusEnum.newShipments;
  void changeSelectedStatus(ShipmentsStatusEnum status) {
    selectedStatus = status;

    emit(ChangeShipmentsStatusState());
    getShipments();
  }

  Driver? selectedDriver;
  void changeSelectedDriver(Driver? driver) {
    if (driver == selectedDriver) {
      selectedDriver = null; // Deselect if the same driver is clicked
      emit(ChangeDriverState());
      return;
    }
    selectedDriver = driver;
    emit(ChangeDriverState());
  }

  bool? enableNotifications;
  void changeEnableNotifications(bool? enable) {
    enableNotifications = enable;
    updateIsNotify(shipmentId: shipmentDetailsModel?.data?.id.toString() ?? "");
    emit(ChangeEnableNotificationsState());
  }

  // Rate
  TextEditingController rateCommentController = TextEditingController();
  double rateValue = 0;
  void changeRateValue(double value) {
    rateValue = value;
    emit(ChangeRateValueState());
  }

  //// API Calls  ////
  GetShipmentsModel? shipmentsModel;
  Future<void> getShipments() async {
    emit(ShipmentsLoadingState());
    try {
      final response = await api.getShipments(
        status: selectedStatus.index.toString(),
      );
      response.fold((failure) => emit(ShipmentsErrorState()), (shipments) {
        shipmentsModel = shipments;
        emit(ShipmentsLoadedState());
      });
    } catch (e) {
      log("Error in getShipments: $e");
      emit(ShipmentsErrorState());
    }
  }

  GetUserShipmentDetailsModel? shipmentDetailsModel;
  Future<void> getShipmentDetails({required String id}) async {
    shipmentDetailsModel = null;
    emit(ShipmentDetailsLoadingState());
    try {
      final response = await api.getShipmentDetails(id: id);
      response.fold((failure) => emit(ShipmentDetailsErrorState()), (
        shipmentDetails,
      ) {
        shipmentDetailsModel = shipmentDetails;
        if (shipmentDetails.data?.isNotify == 1) {
          enableNotifications = true;
        } else {
          enableNotifications = false;
        }
        emit(ShipmentDetailsLoadedState());
      });
    } catch (e) {
      print("Error in getShipmentDetails: $e");
      emit(ShipmentDetailsErrorState());
    }
  }

  Future<void> completeShipment({
    required String shipmentId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(AssignDriverLoadingState());
    try {
      final response = await api.completeShipment(id: shipmentId);
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(AssignDriverErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(AssignDriverLoadedState());

            successGetBar(response.msg ?? "Shipment completed successfully");
            getShipmentDetails(id: shipmentId);
            // Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            // getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to complete shipment");
          }
        },
      );
    } catch (e) {
      log("Error in completeShipment: $e");
      emit(AssignDriverErrorState());
    }
  }

  Future<void> deleteShipment({
    required String shipmentId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "Assigning driver...");
    emit(AssignDriverLoadingState());
    try {
      final response = await api.deleteShipment(id: shipmentId);
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(AssignDriverErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(AssignDriverLoadedState());
            successGetBar(response.msg ?? "Driver assigned successfully");
            Navigator.pushNamed(
              context,
              Routes.mainRoute,
              arguments: false,
            ); // Refresh shipment details
            context.read<UserHomeCubit>().getHome(context);
          } else {
            errorGetBar(response.msg ?? "Failed to assign driver");
          }
        },
      );
    } catch (e) {
      print("Error in assignDriver: $e");
      emit(AssignDriverErrorState());
    }
  }

  Future<void> updateIsNotify({required String shipmentId}) async {
    emit(AssignDriverLoadingState());
    try {
      final response = await api.updateIsNotify(id: shipmentId);
      response.fold(
        (failure) {
          emit(AssignDriverErrorState());
        },
        (response) {
          if (response.status == 200 || response.status == 201) {
            emit(AssignDriverLoadedState());
          } else {
            enableNotifications = !enableNotifications!;
            emit(AssignDriverErrorState());
            errorGetBar(response.msg ?? "Failed to update isNotify");
          }
        },
      );
    } catch (e) {
      print("Error in assignDriver: $e");
      emit(AssignDriverErrorState());
    }
  }

  Future<void> assignDriver({
    required String shipmentId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "Assigning driver...");
    emit(AssignDriverLoadingState());
    try {
      final response = await api.assignDriver(
        shipmentId: shipmentId,
        driverId:
            "selectedDriver?.driverId.toString() ?? "
            "",
      );
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(AssignDriverErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(AssignDriverErrorState());
            successGetBar(response.msg ?? "Driver assigned successfully");
            getShipmentDetails(id: shipmentId); // Refresh shipment details
          } else {
            errorGetBar(response.msg ?? "Failed to assign driver");
          }
        },
      );
    } catch (e) {
      print("Error in assignDriver: $e");
      emit(AssignDriverErrorState());
    }
  }

  Future<void> updateShipmentStatus({
    required String shipmentId,
    required String status,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "Assigning driver...");
    emit(AssignDriverLoadingState());
    try {
      final response = await api.updateShipmentStatus(
        lat: context.read<LocationCubit>().selectedLocation?.latitude,
        long: context.read<LocationCubit>().selectedLocation?.longitude,
        shipmentId: shipmentId,
        status: status,
      );
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(AssignDriverErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(AssignDriverErrorState());
            successGetBar(
              response.msg ?? "Shipment status updated successfully",
            );
            getShipmentDetails(id: shipmentId); // Refresh shipment details
          } else {
            errorGetBar(response.msg ?? "Failed to update shipment status");
          }
        },
      );
    } catch (e) {
      print("Error in assignDriver: $e");
      emit(AssignDriverErrorState());
    }
  }

  Future<void> addRateForDriver({
    required String shipmentId,
    required BuildContext context,
    required String comment,
    required String driverId,
    required double rate,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(AddRateForDriverLoadingState());
    try {
      final response = await api.addRateForDriver(
        shipmentId: shipmentId,
        comment: comment,
        driverrId: driverId,
        rate: rate,
      );
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(AddRateForDriverErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog

          if (response.status == 200 || response.status == 201) {
            Navigator.pop(context); // Close bottom sheet
            emit(AddRateForDriverSuccessState());
            successGetBar(response.msg ?? "Rate added successfully");
            getShipmentDetails(id: shipmentId);
          } else {
            errorGetBar(response.msg ?? "Failed to add rate");
          }
        },
      );
    } catch (e) {
      log("Error in addRateForUser: $e");
      emit(AddRateForDriverErrorState());
    }
  }

  ScreenshotController screenshotController = ScreenshotController();

  captureScreenshot() async {
    Uint8List? imageInUnit8List = await screenshotController
        .capture(); // store unit8List image here ;
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(imageInUnit8List!.toList(growable: true));

    Share.shareXFiles([XFile(file.path)], text: "مشاركة الشحنة");
    emit(ScreenshootState());
  }
}

class ShipMentsStatus {
  final String title;
  final ShipmentsStatusEnum status;
  ShipMentsStatus({required this.title, required this.status});
}
