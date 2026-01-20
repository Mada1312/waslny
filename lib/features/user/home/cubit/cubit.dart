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

class UserHomeCubit extends Cubit<UserHomeState> {
  UserHomeCubit(this.api) : super(UserHomeInitial());

  final UserHomeRepo api;

  ServicesType? serviceType = ServicesType.trips;
  GetUserHomeModel? homeModel;

  // ---- Track current trip by ID (fix .first issue) ----
  int? _trackedTripId;

  // ---- Debounce missing trip ----
  int _missingTripCount = 0;
  static const int _missingTripThreshold = 3; // 3 * 5s = 15 ثانية

  // ---- Prevent showing end dialog twice ----
  final Set<int> _endedDialogShownTripIds = {};

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
  // Helper
  // -------------------------

  TripAndServiceModel? _findTripById(List<TripAndServiceModel>? list, int? id) {
    if (list == null || list.isEmpty || id == null) return null;
    for (final t in list) {
      if (t.id == id) return t;
    }
    return null;
  }

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

    // ✅ User accepted trip (إشعار فقط - ممنوع فتح التقييم هنا)
    if ((oldTrip.isUserAccept ?? 0) != (newTrip.isUserAccept ?? 0) &&
        (newTrip.isUserAccept ?? 0) == 1) {
      log('✅ CAPTAIN ACCEPTED TRIP');
      LocalNotificationService.showCaptainAcceptedNotification(
        captainName: newTrip.driver?.name ?? 'الكابتن',
      );
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
            final tripsList = serviceType?.name == ServicesType.services.name
                ? data.data?.services
                : data.data?.trips;

            // ✅ اختار نفس الرحلة اللي بتتابعها بالـ id
            TripAndServiceModel? currentTrip;
            if (_trackedTripId != null) {
              currentTrip = _findTripById(tripsList, _trackedTripId);
            } else {
              // أول مرة: امسك أول رحلة وابدأ تتبعها
              currentTrip = (tripsList?.isNotEmpty == true)
                  ? tripsList!.first
                  : null;
              _trackedTripId = currentTrip?.id;
            }

            // ✅ 1) الرحلة اختفت مؤقتًا؟
            if (_lastTrip != null && currentTrip == null) {
              _missingTripCount++;

              // ما نعتبرهاش انتهت إلا بعد اختفاء متكرر
              if (_missingTripCount >= _missingTripThreshold) {
                final id = _lastTrip!.id;

                if (id != null && !_endedDialogShownTripIds.contains(id)) {
                  _endedDialogShownTripIds.add(id);

                  log('✨ TRIP ENDED (confirmed)');
                  LocalNotificationService.showTripEndedNotification();

                  _stopPolling();
                  emit(TripEndedState(_lastTrip!));

                  // تنظيف التتبع
                  _trackedTripId = null;
                  _lastTrip = null;
                  _missingTripCount = 0;
                  homeModel = data;

                  return; // مهم: ما تعملش emit(UserHomeLoaded) بعدها
                }
              }
            }
            // ✅ 2) الرحلة موجودة ومستمرّة
            else if (_lastTrip != null && currentTrip != null) {
              _missingTripCount = 0;
              _detectTripChangesAndNotify(_lastTrip!, currentTrip);

              _lastTrip = currentTrip;
              _trackedTripId = currentTrip.id;
            }
            // ✅ 3) أول مرة تمسك رحلة
            else if (_lastTrip == null && currentTrip != null) {
              _missingTripCount = 0;
              _lastTrip = currentTrip;
              _trackedTripId = currentTrip.id;
            }
            // ✅ 4) لا توجد رحلة
            else {
              _missingTripCount = 0;
              _lastTrip = null;
              _trackedTripId = null;
            }

            homeModel = data;
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

      _trackedTripId = _lastTrip?.id;
      _missingTripCount = 0;
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
