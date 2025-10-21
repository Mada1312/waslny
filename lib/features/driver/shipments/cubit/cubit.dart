import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/shipments/screens/data/models/get_shipments_model.dart';
import 'package:waslny/features/driver/shipments/screens/data/models/shipment_details_model.dart';
import '../screens/data/repo.dart';
import 'state.dart';

enum ShipmentsStatusEnum { newShipments, pending, loaded, delivered }

class DriverShipmentsCubit extends Cubit<DriverShipmentsState> {
  DriverShipmentsCubit(this.api) : super(DriverShipmentsInitial());

  DriverShipmentsRepo api;

  ShipmentsStatusEnum selectedStatus = ShipmentsStatusEnum.newShipments;
  void changeSelectedStatus(ShipmentsStatusEnum status) {
    selectedStatus = status;
    emit(ChangeShipmentsStatusState());
  }

  int? selectedDriver;
  void changeSelectedDriver(int? driverId) {
    selectedDriver = driverId;
    emit(ChangeDriverState());
  }

  bool? enableNotifications;
  void changeEnableNotifications(bool? enable) {
    enableNotifications = enable;
    emit(ChangeEnableNotificationsState());
  }

// Rate
  TextEditingController rateCommentController = TextEditingController();
  double rateValue = 0;
  void changeRateValue(double value) {
    rateValue = value;
    emit(ChangeRateValueState());
  }
  //// API Calls ////

  GetDriverShipmentsModel? shipmentsModel;
  Future<void> getShipments() async {
    emit(GetShipmentsLoadingState());
    try {
      var response = await api.getDriverShipments();
      response.fold(
        (failure) => emit(GetShipmentsErrorState()),
        (shipments) {
          shipmentsModel = shipments;
          emit(GetShipmentsSuccessState());
        },
      );
    } catch (e) {
      log("Error in getShipments: $e");
      emit(GetShipmentsErrorState());
    }
  }

  GetDriverShipmentDetailsModel? shipmentDetails;
  Future<void> getShipmentDetails({required String id}) async {
    shipmentDetails = null;
    try {
      emit(GetShipmentDetailsLoadingState());
      var response = await api.getDriverShipmentDetails(id: id);
      response.fold(
        (failure) => emit(GetShipmentDetailsErrorState()),
        (details) {
          shipmentDetails = details;
          emit(GetShipmentDetailsSuccessState());
        },
      );
    } catch (e) {
      log("Error in getShipmentDetails: $e");
      emit(GetShipmentDetailsErrorState());
    }
  }

  Future<void> requestShipment(
      {required String shipmentId, required BuildContext context}) async {
    AppWidget.createProgressDialog(context, msg: "Assigning driver...");
    emit(RequestShipmentLoadingState());
    try {
      final response = await api.requestShipment(
        id: shipmentId,
      );
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(RequestShipmentErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(RequestShipmentSuccessState());
            successGetBar(
              response.msg ?? "success",
            );
            Navigator.pushNamed(context, Routes.mainRoute,
                arguments: true); // Refresh shipment details
          } else {
            errorGetBar(
              response.msg ?? "Failed",
            );
          }
        },
      );
    } catch (e) {
      print(": Error in requestShipment: $e");
      emit(RequestShipmentErrorState());
    }
  }

  Future<void> cancelRequestShipment(
      {required String shipmentId, required BuildContext context}) async {
    AppWidget.createProgressDialog(context, msg: "Assigning driver...");
    emit(RequestShipmentLoadingState());
    try {
      final response = await api.cancelRequestShipment(
        id: shipmentId,
      );
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(RequestShipmentErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(RequestShipmentSuccessState());
            successGetBar(
              response.msg ?? "success",
            );
            Navigator.pushNamed(context, Routes.mainRoute,
                arguments: true); // Refresh shipment details
          } else {
            errorGetBar(
              response.msg ?? "Failed",
            );
          }
        },
      );
    } catch (e) {
      print("Error in cancelRequestShipment: $e");
      emit(RequestShipmentErrorState());
    }
  }

  Future<void> addRateForUser(
      {required String shipmentId,
      required BuildContext context,
      required String comment,
      required String userId,
      required double rate}) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(AddRateForUserLoadingState());
    try {
      final response = await api.addRateForUser(
          shipmentId: shipmentId, comment: comment, userId: userId, rate: rate);
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(AddRateForUserErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog

          if (response.status == 200 || response.status == 201) {
            Navigator.pop(context); // Close bottom sheet
            emit(AddRateForUserSuccessState());
            successGetBar(
              response.msg ?? "Rate added successfully",
            );
            getShipmentDetails(id: shipmentId);
          } else {
            errorGetBar(
              response.msg ?? "Failed to add rate",
            );
          }
        },
      );
    } catch (e) {
      log("Error in addRateForUser: $e");
      emit(AddRateForUserErrorState());
    }
  }
}

class ShipMentsStatus {
  final String title;
  final ShipmentsStatusEnum status;
  ShipMentsStatus({
    required this.title,
    required this.status,
  });
}
