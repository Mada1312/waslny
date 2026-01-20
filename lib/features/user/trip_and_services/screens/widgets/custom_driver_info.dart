import 'dart:developer';

import 'package:waslny/core/exports.dart';

import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/general/navigation/user_tracking_screen.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';

import '../../../driver_details/screens/driver_details.dart';
import 'call_message.dart';

class CustomDriverInfo extends StatefulWidget {
  const CustomDriverInfo({
    super.key,
    this.hint,
    this.driver,
    this.shipmentCode,
    this.roomToken,
    this.tripId,
    this.isFavWidget,
    this.onTapToCancelTrip,
    this.isCancelable = true,
    this.trip,
  });
  final String? hint;
  final String? shipmentCode;
  final String? tripId;
  final String? roomToken;
  final Driver? driver;
  final bool? isFavWidget;
  final void Function()? onTapToCancelTrip;
  final bool isCancelable;
  final TripAndServiceModel? trip;
  @override
  State<CustomDriverInfo> createState() => _CustomDriverInfoState();
}

class _CustomDriverInfoState extends State<CustomDriverInfo> {
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<UserTripAndServicesCubit>();
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 30.h),
                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.second5Primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Image.asset(
                  widget.trip?.isService == 1
                      ? ImageAssets.service
                      : ImageAssets.trip,
                  height: 30.sp,
                  width: 30.sp,
                  // imageColor: AppColors.secondPrimary,
                ),
              ),
              10.w.horizontalSpace,
              Expanded(
                child: CustomDriverCardInfo(
                  driver: widget.driver,
                  shipmentCode: widget.shipmentCode,
                  tripId: widget.tripId,
                ),
              ),
            ],
          ),
        ),

        10.w.horizontalSpace,
        Row(
          children: [
            if (widget.trip?.isUserAccept == 0) ...[
              Flexible(
                flex: 3,
                child: CustomButton(
                  title: widget.trip?.isService == 1
                      ? "accept_service".tr()
                      : "accept_trip".tr(),
                  height: 40.h,

                  fontSize: 14.sp,

                  onPressed: () {
                    widget.trip?.isService == 1
                        ? cubit.updateTripStatus(
                            id: widget.trip?.id ?? 0,
                            step: TripStep.isUserAccept,
                            context: context,
                          )
                        : warningDialog(
                            context,
                            title: "are_you_sure_you_want_to_accept_trip".tr(),
                            onPressedOk: () {
                              cubit.updateTripStatus(
                                id: widget.trip?.id ?? 0,
                                step: TripStep.isUserAccept,
                                context: context,
                              );
                            },
                          );
                  },
                ),
              ),
              10.w.horizontalSpace,
            ],
            if (widget.trip?.isUserStartTrip == 0 &&
                widget.trip?.isUserAccept == 1 &&
                widget.trip?.isUserChangeCaptain == 0 &&
                widget.trip?.isService == 0) ...[
              Flexible(
                flex: 3,
                child: CustomButton(
                  title: widget.trip?.isService == 1
                      ? "start_service".tr()
                      : "start_trip".tr(),
                  height: 40.h,
                  fontSize: 14.sp,
                  isDisabled:
                      widget.trip?.isDriverAccept == 0 ||
                      widget.trip?.isDriverArrived == 0,
                  onPressed: () {
                    // ✅ خادم واحد للحالتين (خدمة أو رحلة عادية)
                    cubit
                        .updateTripStatus(
                          id: widget.trip?.id ?? 0,
                          step: TripStep.isUserStartTrip,
                          context: context,
                        )
                        .then((_) {
                          // ✅ بعد النجاح → افتح UserTrackingScreen
                          if (widget.trip != null) {
                            // استخدم الـ trip من widget مباشرة
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<UserHomeCubit>(),
                                  child: UserTrackingScreen(
                                    trip: widget.trip!,
                                    mode: UserTrackingMode.toDestination,
                                  ),
                                ),
                              ),
                            );
                          }
                        })
                        .catchError((e) {
                          // ✅ في حالة الفشل - لا تفتح الصفحة
                          log("Error starting trip: $e");
                        });
                  },
                ),
              ),
              10.w.horizontalSpace,
            ],
            if (widget.trip?.isUserChangeCaptain == 0 &&
                widget.trip?.isDriverAccept == 0)
              Flexible(
                flex: 2,
                child: CustomButton(
                  title: "change_captain".tr(),
                  height: 40.h,
                  fontSize: 14.sp,

                  btnColor: AppColors.secondPrimary,
                  textColor: AppColors.primary,
                  onPressed: () {
                    warningDialog(
                      context,
                      title: "are_you_sure_you_want_to_change_captain".tr(),
                      onPressedOk: () {
                        cubit.updateTripStatus(
                          id: widget.trip?.id ?? 0,

                          step: TripStep.isUserChangeCaptain,
                          context: context,
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
        10.w.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.trip?.isDriverStartTrip == 0) ...[
              Flexible(
                flex: 3,
                child: CustomButton(
                  title: widget.trip?.isService == 1
                      ? "cancel_service".tr()
                      : "cancel_trip".tr(),
                  onPressed: widget.onTapToCancelTrip,
                  height: 40.h,
                  fontSize: 14.sp,
                  btnColor: AppColors.red,
                  textColor: AppColors.white,
                ),
              ),
              10.h.horizontalSpace,
            ],
            Flexible(
              flex: 2,
              child: Center(
                child: CustomCallAndMessageWidget(
                  driverId:
                      widget.driver?.id?.toString() ??
                      widget.driver?.id?.toString(),
                  receiverId: widget.driver?.id?.toString() ?? '',
                  name: widget.driver?.name ?? '',
                  tripId: widget.tripId,
                  roomToken: widget.roomToken,
                  shipmentCode: widget.shipmentCode,
                  phoneNumber: widget.driver?.phone.toString(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomDriverCardInfo extends StatelessWidget {
  const CustomDriverCardInfo({
    super.key,
    this.driver,
    this.tripId,
    this.shipmentCode,
  });
  final Driver? driver;
  final String? tripId;
  final String? shipmentCode;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverProfileScreen(
                driverId: driver?.id.toString() ?? '',

                tripId: tripId,
                shipmentCode: shipmentCode,
              ),
            ),
          );
        },
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 30.h),
              padding: EdgeInsets.all(5.h),
              decoration: BoxDecoration(
                color: AppColors.second5Primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  60.w.horizontalSpace,
                  Flexible(
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            driver?.name ?? '',
                            maxLines: 1,
                            style: getSemiBoldStyle(
                              fontSize: 16.sp,
                              color: AppColors.secondPrimary,
                            ),
                          ),

                          Text(
                            driver?.vehiclePlateNumber ?? '',
                            maxLines: 1,
                            style: getRegularStyle(
                              fontSize: 12.sp,
                              color: AppColors.secondPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CustomNetworkImage(
                image: driver?.image ?? "",
                isUser: true,
                borderRadius: 100,
                height: 60.h,
                width: 60.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
