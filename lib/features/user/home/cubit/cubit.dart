import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/notification_services/service/local_notification_service.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/price/pricing_widget.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

import '../data/repo.dart';
import 'state.dart';

class UserHomeCubit extends Cubit<UserHomeState> {
  UserHomeCubit(this.api) : super(UserHomeInitial());

  UserHomeRepo api;
  ServicesType? serviceType = ServicesType.trips;
  GetUserHomeModel? homeModel;

  // Rate
  TextEditingController rateCommentController = TextEditingController();
  double rateValue = 3.0;

  // ✅ Polling
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 5);

  // ✅ Track trip states to detect changes
  TripAndServiceModel? _lastTrip;

  Future<void> getHome(BuildContext context, {bool? isVerify = false}) async {
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

      if (homeModel?.data?.unRatedTripId != null) {
        _stopPolling(); // ✅ توقف الـ polling لو في تقييم
        rateCommentController.clear();
        rateValue = 0;
        emit(ChangeRateValueState());
        rateTripDialog(
          context,
          btnOkText: 'done'.tr(),
          title: 'reviewing_data'.tr(),
        );
      } else {
        _startPolling(context); // ✅ ابدأ polling لو ما في تقييم
      }
      emit(UserHomeLoaded());
    });
  }

  // ✅ Start Polling
  void _startPolling(BuildContext context) {
    if (_pollingTimer != null) return;

    log('🔄 Starting Polling for User...');

    _pollingTimer = Timer.periodic(_pollingInterval, (_) async {
      try {
        final result = await api.getHome(
          type: serviceType?.name == ServicesType.services.name ? '1' : '0',
        );

        result.fold(
          (failure) {
            log("⚠️ Polling error");
          },
          (data) {
            if (data.status == 200 || data.status == 201) {
              // ✅ احصل على الـ trip الأخير (الحالي)
              final newTrips = serviceType?.name == ServicesType.services.name
                  ? data.data?.services
                  : data.data?.trips;
              final newTrip = newTrips?.isNotEmpty == true
                  ? newTrips?.first
                  : null;

              homeModel = data;

              // ✅ اكتشف التغييرات وأرسل الإشعارات
              if (newTrip != null && _lastTrip != null) {
                _detectTripChangesAndNotify(_lastTrip!, newTrip);
              }

              // ✅ تحقق من انهاء الرحلة (الرحلة اختفت من القائمة)
              if (_lastTrip != null && newTrip == null) {
                log('✨ TRIP COMPLETED');
                LocalNotificationService.showTripEndedNotification();

                // **هنا تضيف السطور دي بس:**
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => PricingDialog(
                    trip: _lastTrip as DriverTripModel,
                    isFemaleDriver: false,
                    onConfirm: () async {
                      Navigator.pop(context);

                      rateCommentController.clear();
                      rateValue = 0;
                      emit(ChangeRateValueState());
                      await rateTripDialog(
                        context,
                        btnOkText: 'done'.tr(),
                        title: 'reviewing_data'.tr(),
                      );
                    },
                  ),
                );
              }

              // ✅ حدّث الـ last trip
              _lastTrip = newTrip;

              // لو ظهر تقييم جديد
              if (homeModel?.data?.unRatedTripId != null) {
                _stopPolling();
                rateCommentController.clear();
                rateValue = 0;
                emit(ChangeRateValueState());
                rateTripDialog(
                  context,
                  btnOkText: 'done'.tr(),
                  title: 'reviewing_data'.tr(),
                );
              }

              emit(UserHomeLoaded());
              log('🔄 Home updated (polling)');
            }
          },
        );
      } catch (e) {
        log("❌ Polling error: $e");
      }
    });
  }

  // ✅ Detect trip changes and send notifications
  void _detectTripChangesAndNotify(
    TripAndServiceModel oldTrip,
    TripAndServiceModel newTrip,
  ) {
    // ✅ تحقق من تعيين كابتن جديد
    if ((oldTrip.isDriverAccept ?? 0) != (newTrip.isDriverAccept ?? 0) &&
        (newTrip.isDriverAccept ?? 0) == 1) {
      log('🚗 CAPTAIN ASSIGNED');
      LocalNotificationService.showCaptainAssignedNotification(
        captainName: newTrip.driver?.name ?? 'الكابتن',
      );
    }

    // ✅ تحقق من قبول الكابتن للرحلة
    if ((oldTrip.isUserAccept ?? 0) != (newTrip.isUserAccept ?? 0) &&
        (newTrip.isUserAccept ?? 0) == 1) {
      log('✅ CAPTAIN ACCEPTED TRIP');
      LocalNotificationService.showCaptainAcceptedNotification(
        captainName: newTrip.driver?.name ?? 'الكابتن',
      );
    }

    // ✅ تحقق من وصول الكابتن
    if ((oldTrip.isDriverArrived ?? 0) != (newTrip.isDriverArrived ?? 0) &&
        (newTrip.isDriverArrived ?? 0) == 1) {
      log('📍 CAPTAIN ARRIVED');
      LocalNotificationService.showCaptainArrivedNotification(
        captainName: newTrip.driver?.name ?? 'الكابتن',
      );
    }

    // ✅ تحقق من بدء الرحلة
    if ((oldTrip.isDriverStartTrip ?? 0) != (newTrip.isDriverStartTrip ?? 0) &&
        (newTrip.isDriverStartTrip ?? 0) == 1) {
      log('🚗 TRIP STARTED');
      LocalNotificationService.showTripStartedNotification();
    }
  }

  // ✅ Stop Polling
  void _stopPolling() {
    if (_pollingTimer != null) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
      log('⏹️ Polling stopped');
    }
  }

  void changeRateValue(double value) {
    rateValue = value;
    emit(ChangeRateValueState());
  }

  // ✅ استقبال Context لتجنب الـ crash
  Future<void> skipRate(BuildContext context) async {
    _startPolling(context);
    await api.skipRate(tripId: homeModel?.data?.unRatedTripId.toString() ?? "");
  }

  // ✅ بدون رسايل يدوية - الاعتماد على الـ Polling فقط
  Future<void> addRateForDriver({required BuildContext context}) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(AddRateForDriverLoadingState());
    try {
      final response = await api.addRateForDriver(
        tripId: homeModel?.data?.unRatedTripId.toString() ?? "",
        comment: rateCommentController.text,
        rate: rateValue,
      );
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(AddRateForDriverErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog

          if (response.status == 200 || response.status == 201) {
            Navigator.pop(context); // Close rating dialog
            emit(AddRateForDriverSuccessState());

            // ✅ ابدأ polling بعد التقييم
            _startPolling(context);
          }
        },
      );
    } catch (e) {
      log("Error in addRateForUser: $e");
      emit(AddRateForDriverErrorState());
    }
  }

  // ✅ Dispose
  @override
  Future<void> close() {
    _stopPolling();
    rateCommentController.dispose();
    return super.close();
  }
}

Future<void> rateTripDialog(
  BuildContext context, {
  void Function()? onPressedOk,
  String? title,
  String? btnOkText,
  String? desc,
}) async {
  await showGeneralDialog(
    context: context,
    barrierLabel: "WarningDialog",
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return BlocBuilder<UserHomeCubit, UserHomeState>(
        builder: (context, state) {
          var cubit = context.read<UserHomeCubit>();
          GlobalKey<FormState> formKey = GlobalKey<FormState>();
          return WillPopScope(
            onWillPop: () async => false,
            child: Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: anim1,
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      // ✅ تمرير الـ Context هنا لتجنب الخطأ
                                      cubit.skipRate(context);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.black,
                                      size: 30.sp,
                                    ),
                                  ),
                                ),
                                Text(
                                  "rate_driver".tr(),
                                  textAlign: TextAlign.center,
                                  style: getSemiBoldStyle(fontSize: 18.sp),
                                ),
                                10.verticalSpace,
                                CustomTextField(
                                  hintText: "write_comment".tr(),
                                  isMessage: true,
                                  isRequired: false,
                                  controller: cubit.rateCommentController,
                                ),
                                10.verticalSpace,
                                RatingBar.builder(
                                  initialRating: cubit.rateValue,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 30.sp,
                                  itemPadding: const EdgeInsets.symmetric(
                                    horizontal: 0.0,
                                  ),
                                  itemBuilder: (context, _) => Icon(
                                    CupertinoIcons.star_fill,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {
                                    cubit.changeRateValue(rating);
                                  },
                                ),
                                20.verticalSpace,
                                CustomButton(
                                  title: "confirm".tr(),
                                  onPressed: () {
                                    cubit.addRateForDriver(context: context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
