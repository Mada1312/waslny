import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/core/notification_services/service/local_notification_service.dart';
import '../data/models/get_home_model.dart';
import '../data/repo.dart';
import 'state.dart';

class TripCompletedState extends UserHomeState {
  final TripAndServiceModel trip;
  TripCompletedState(this.trip);
}

class UserHomeCubit extends Cubit<UserHomeState> {
  UserHomeCubit(this.api) : super(UserHomeInitial());

  final UserHomeRepo api;

  ServicesType? serviceType = ServicesType.trips;
  GetUserHomeModel? homeModel;

  // Rate
  final TextEditingController rateCommentController = TextEditingController();
  double rateValue = 3.0;

  // Polling
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 5);
  bool _isPollingActive = false;
  TripAndServiceModel? _lastTrip;

  // Track trips that already fired dialogs
  final Set<int> _notifiedTripIds = {};

  // -------------------------
  // Detect trip changes and send notifications
  // -------------------------
  void _detectTripChangesAndNotify(
    TripAndServiceModel oldTrip,
    TripAndServiceModel newTrip,
  ) {
    // ✅ Captain assigned
    if ((oldTrip.isDriverAccept ?? 0) != (newTrip.isDriverAccept ?? 0) &&
        (newTrip.isDriverAccept ?? 0) == 1) {
      log('🚗 CAPTAIN ASSIGNED');
      LocalNotificationService.showCaptainAssignedNotification(
        captainName: newTrip.driver?.name ?? 'الكابتن',
      );
    }

    // ✅ User accepted trip → emit TripCompletedState to show Dialog
    if ((oldTrip.isUserAccept ?? 0) != (newTrip.isUserAccept ?? 0) &&
        (newTrip.isUserAccept ?? 0) == 1) {
      log('✅ CAPTAIN ACCEPTED TRIP');
      LocalNotificationService.showCaptainAcceptedNotification(
        captainName: newTrip.driver?.name ?? 'الكابتن',
      );

      if (newTrip.id != null && !_notifiedTripIds.contains(newTrip.id)) {
        _notifiedTripIds.add(newTrip.id!);
        emit(TripCompletedState(newTrip));
      }
    }

    // ✅ Captain arrived
    if ((oldTrip.isDriverArrived ?? 0) != (newTrip.isDriverArrived ?? 0) &&
        (newTrip.isDriverArrived ?? 0) == 1) {
      log('📍 CAPTAIN ARRIVED');
      LocalNotificationService.showCaptainArrivedNotification(
        captainName: newTrip.driver?.name ?? 'الكابتن',
      );
    }

    // ✅ Trip started
    if ((oldTrip.isDriverStartTrip ?? 0) != (newTrip.isDriverStartTrip ?? 0) &&
        (newTrip.isDriverStartTrip ?? 0) == 1) {
      log('🚗 TRIP STARTED');
      LocalNotificationService.showTripStartedNotification();
    }
  }

  // -------------------------
  // Start Polling
  // -------------------------
  void _startPolling() {
    if (_isPollingActive) return;
    _isPollingActive = true;

    log('🔄 Starting Polling for User...');

    _pollingTimer = Timer.periodic(_pollingInterval, (_) async {
      if (isClosed) return;

      try {
        final result = await api.getHome(
          type: serviceType?.name == ServicesType.services.name ? '1' : '0',
        );

        result.fold((failure) => log("⚠️ Polling error"), (data) {
          if (isClosed) return;

          if (data.status == 200 || data.status == 201) {
            final newTrips = serviceType?.name == ServicesType.services.name
                ? data.data?.services
                : data.data?.trips;

            final newTrip = newTrips?.isNotEmpty == true
                ? newTrips?.first
                : null;

            // ✅ Trip completed (disappeared)
            // if (_lastTrip != null && newTrip == null) {
            //   log('✨ TRIP COMPLETED');
            //   LocalNotificationService.showTripEndedNotification();

            //   final completedTrip = _lastTrip!;
            //   final int tripId = completedTrip.id ?? 0;

            //   if (!_notifiedTripIds.contains(tripId)) {
            //     _notifiedTripIds.add(tripId);
            //     emit(TripCompletedState(completedTrip));
            //   }
            // }
            if (_lastTrip != null && newTrip == null) {
              if (_lastTrip!.isCancelled == true) {
                log('🚫 Trip was cancelled by user');
                LocalNotificationService.showTripCancelledNotification();
                // ما تعرضش السعر أو التقييم
              } else {
                log('✨ Trip completed normally');
                LocalNotificationService.showTripEndedNotification();

                if (!_notifiedTripIds.contains(_lastTrip!.id)) {
                  _notifiedTripIds.add(_lastTrip!.id!);
                  emit(TripCompletedState(_lastTrip!));
                }
              }
            }

            // ✅ Detect normal changes
            if (_lastTrip != null && newTrip != null) {
              _detectTripChangesAndNotify(_lastTrip!, newTrip);
            }

            homeModel = data;
            _lastTrip = newTrip;
            emit(UserHomeLoaded());
          }
        });
      } catch (e) {
        log("❌ Polling error: $e");
      }
    });
  }

  // -------------------------
  // Stop Polling
  // -------------------------
  void _stopPolling() {
    if (_pollingTimer != null) {
      _pollingTimer!.cancel();
      _pollingTimer = null;
    }
    _isPollingActive = false;
    log('⏹️ Polling stopped');
  }

  // -------------------------
  // Get Home
  // -------------------------
  Future<void> getHome(BuildContext context) async {
    emit(UserHomeLoading());

    final result = await api.getHome(
      type: serviceType?.name == ServicesType.services.name ? '1' : '0',
    );

    result.fold((failure) => emit(UserHomeError()), (data) {
      if (data.status != 200 && data.status != 201) {
        emit(UserHomeError());
        return;
      }

      homeModel = data;

      _lastTrip =
          (serviceType?.name == ServicesType.services.name
                      ? data.data?.services
                      : data.data?.trips)
                  ?.isNotEmpty ==
              true
          ? (serviceType?.name == ServicesType.services.name
                ? data.data!.services!.first
                : data.data!.trips!.first)
          : null;

      _startPolling();
      emit(UserHomeLoaded());
    });
  }

  // -------------------------
  // Rate logic
  // -------------------------
  void changeRateValue(double value) {
    rateValue = value;
    emit(ChangeRateValueState());
  }

  Future<void> addRateForDriver({
    required BuildContext context,
    required String tripId,
  }) async {
    if (!context.mounted) return;

    AppWidget.createProgressDialog(context, msg: "جاري إرسال التقييم...");
    emit(AddRateForDriverLoadingState());

    try {
      final response = await api.addRateForDriver(
        tripId: tripId,
        comment: rateCommentController.text,
        rate: rateValue,
      );

      if (!context.mounted) {
        Navigator.pop(context);
        return;
      }

      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(AddRateForDriverErrorState());
        },
        (res) {
          Navigator.pop(context); // Close progress dialog

          if (res.status == 200 || res.status == 201) {
            Navigator.pop(context); // Close rating dialog
            emit(AddRateForDriverSuccessState());
            successGetBar(res.msg ?? "تم إرسال التقييم بنجاح");

            if (!_isPollingActive) {
              _startPolling();
            }
          } else {
            errorGetBar(res.msg ?? "فشل إرسال التقييم");
          }
        },
      );
    } catch (e) {
      log("❌ Error in addRateForDriver: $e");
      if (context.mounted) {
        Navigator.pop(context);
      }
      emit(AddRateForDriverErrorState());
    }
  }

  @override
  Future<void> close() {
    _stopPolling();
    rateCommentController.dispose();
    return super.close();
  }
}
