import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

  // Rate
  TextEditingController rateCommentController = TextEditingController();
  double rateValue = 3.0;

  // ✅ Polling
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 5);

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

    log('🔄 Starting Polling...');

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
              homeModel = data;

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

  Future<void> skipRate() async {
    _startPolling(null as BuildContext); // ✅ ابدأ polling لما يتخطى التقييم
    await api.skipRate(tripId: homeModel?.data?.unRatedTripId.toString() ?? "");
  }

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

            successGetBar(response.msg ?? "Rate added successfully");
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
                                      cubit.skipRate();
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
