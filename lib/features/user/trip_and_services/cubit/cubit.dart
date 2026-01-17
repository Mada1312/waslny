import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../data/repo.dart';
import 'state.dart';

enum ShipmentsStatusEnum { newShipments, pending, loaded, delivered }

class UserTripAndServicesCubit extends Cubit<UserTripAndServicesState> {
  UserTripAndServicesCubit(this.api) : super(ShipmentsInitial());

  UserShipmentsRepo api;
  ShipmentsStatusEnum selectedStatus = ShipmentsStatusEnum.newShipments;

  // ✅ ETA & Timer Logic
  Timer? _etaTimer;
  int remainingSecondsToArrival = 0;
  bool isDriverWaiting = false;

  String get formattedArrivalETA {
    if (isDriverWaiting) return "وصل الكابتن";
    if (remainingSecondsToArrival <= 0) return "قريباً";

    final minutes = remainingSecondsToArrival ~/ 60;
    final seconds = remainingSecondsToArrival % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void startArrivalCountdown(int initialMinutes) {
    _etaTimer?.cancel();
    isDriverWaiting = false;
    remainingSecondsToArrival = initialMinutes * 60;

    _etaTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSecondsToArrival > 0) {
        remainingSecondsToArrival--;
        emit(UpdateTripStatusSuccessState()); // تحديث الواجهة كل ثانية
      } else {
        timer.cancel();
        emit(UpdateTripStatusSuccessState());
      }
    });
  }

  // ✅ دالة إيقاف العداد
  void stopArrivalCountdown() {
    _etaTimer?.cancel();
    remainingSecondsToArrival = 0;
    isDriverWaiting = false;
  }

  // ✅ Pricing Engine (حساب السعر بناءً على مسافة المسار)
  double calculateTripPrice(double totalDistanceMeters, double pricePerKm) {
    double distanceInKm = totalDistanceMeters / 1000;
    return distanceInKm * pricePerKm;
  }

  //!TRIP AND SERVICES

  changeFavOfTripAndService(TripAndServiceModel model) async {
    emit(LoadingChangeStatusOfTripAndServiceState());
    try {
      final response = await api.changeFavOfTripAndService(
        model!.id.toString(),
      );
      response.fold(
        (failure) => emit(ErrorChangeStatusOfTripAndServiceState()),
        (success) {
          if (success.status == 200) {
            model?.isFav = !(model.isFav ?? false);
            successGetBar(success.msg);
            emit(LoadedChangeStatusOfTripAndServiceState());
          } else {
            errorGetBar(success.msg ?? 'Failed to change status');
            emit(ErrorChangeStatusOfTripAndServiceState());
          }
        },
      );
    } catch (e) {
      log("Error in Fav: $e");
      emit(ErrorChangeStatusOfTripAndServiceState());
    }
  }

  Future<void> updateTripStatus({
    required TripStep step,
    required int id,
    required BuildContext context,
  }) async {
    // التحقق من الموقع عند الوصول
    if (step == TripStep.isDriverArrived) {
      if (context.read<LocationCubit>().currentLocation == null) {
        await context.read<LocationCubit>().checkAndRequestLocationPermission(
          context,
        );
      }
      if (context.read<LocationCubit>().currentLocation == null) {
        errorGetBar("location_required".tr());
        return;
      }
    }

    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());

    try {
      final response = await api.updateTripStatus(
        id: id,
        step: step,
        arrivalLat: step != TripStep.isDriverArrived
            ? null
            : context.read<LocationCubit>().currentLocation?.latitude,
        arrivalLong: step != TripStep.isDriverArrived
            ? null
            : context.read<LocationCubit>().currentLocation?.longitude,
      );

      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            // ✅ إدارة حالات العداد التنازلي
            if (step == TripStep.isDriverArrived) {
              stopArrivalCountdown();
              isDriverWaiting = true;
            } else if (step == TripStep.isDriverStartTrip ||
                step == TripStep.isUserStartTrip) {
              stopArrivalCountdown();
            }

            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Status updated successfully");
            context.read<UserHomeCubit>().getHome(context);
          } else {
            errorGetBar(response.msg ?? "Failed to update status");
          }
        },
      );
    } catch (e) {
      log("Error in updateTripStatus: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  // Rate logic
  TextEditingController rateCommentController = TextEditingController();
  double rateValue = 0;
  void changeRateValue(double value) {
    rateValue = value;
    emit(ChangeRateValueState());
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
          Navigator.pop(context);
          emit(AddRateForDriverErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            Navigator.pop(context);
            emit(AddRateForDriverSuccessState());
            successGetBar(response.msg ?? "Rate added successfully");
          } else {
            errorGetBar(response.msg ?? "Failed to add rate");
          }
        },
      );
    } catch (e) {
      log("Error in addRateForDriver: $e");
      emit(AddRateForDriverErrorState());
    }
  }

  ScreenshotController screenshotController = ScreenshotController();

  captureScreenshot() async {
    Uint8List? imageInUnit8List = await screenshotController.capture();
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(imageInUnit8List!.toList(growable: true));
    Share.shareXFiles([XFile(file.path)], text: "مشاركة الشحنة");
    emit(ScreenshootState());
  }

  GetUserHomeModel? completedTripsModel;
  getCompletedTripsAndServices(ServicesType serviceType, bool isDriver) async {
    emit(LoadingCompletedTripAndServiceState());
    final res = await api.getCompletedTripsAndServices(
      type: serviceType.name == ServicesType.trips.name ? '0' : '1',
    );
    res.fold(
      (failure) {
        log("Error in getCompletedTripsAndServices");
        emit(ErrorCompletedTripAndServiceState());
      },
      (r) {
        completedTripsModel = r;
        emit(LoadedCompletedTripAndServiceState());
      },
    );
  }

  Future<void> cancelTrip(String tripId) async {
    emit(LoadingCancelTripAndServiceState());
    final res = await api.cancelTrip(tripId: tripId);
    res.fold(
      (failure) {
        log("Error in cancelTrip");
        emit(ErrorCancelTripAndServiceState());
      },
      (r) {
        successGetBar(r.msg ?? "تم إلغاء الرحلة بنجاح");
        emit(LoadedCancelTripAndServiceState());
      },
    );
  }

  @override
  Future<void> close() {
    _etaTimer?.cancel();
    return super.close();
  }
}

class ShipMentsStatus {
  final String title;
  final ShipmentsStatusEnum status;
  ShipMentsStatus({required this.title, required this.status});
}
