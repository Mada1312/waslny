import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/trips/data/models/get_trips_model.dart';
import 'package:waslny/features/driver/trips/data/models/shipment_details_model.dart';
import '../data/repo.dart';
import 'state.dart';

class DriverTripsCubit extends Cubit<DriverTripsState> {
  DriverTripsCubit(this.api) : super(DriverTripsInitial());

  DriverShipmentsRepo api;


  
  //// API Calls ////

  GetDriverTripsModel? getTripsModel;
  Future<void> getTrips() async {
    emit(GetTripsLoadingState());
    try {
      var response = await api.getDriverScheduleTrips();
      response.fold((failure) => emit(GetTripsErrorState()), (shipments) {
        getTripsModel = shipments;
        emit(GetTripsSuccessState());
      });
    } catch (e) {
      log("Error in getShipments: $e");
      emit(GetTripsErrorState());
    }
  }
 Future<void> cancleTrip({
    required int tripId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await api.cancleTrip(id: tripId);
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip cancelled successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            getTrips();
          } else {
            errorGetBar(response.msg ?? "Failed to cancel trip");
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(UpdateTripStatusErrorState());
    }
  }
}
