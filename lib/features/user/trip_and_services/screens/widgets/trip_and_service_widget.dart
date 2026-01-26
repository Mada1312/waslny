import 'dart:developer';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_divider.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/cubit/state.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/cubit/state.dart';
import 'package:waslny/features/general/navigation/user_tracking_screen.dart';
import 'custom_driver_info.dart';
import 'custom_from_to.dart';

class TripOrServiceItemWidget extends StatefulWidget {
  const TripOrServiceItemWidget({
    super.key,
    this.isDelivered = false,
    this.tripOrService,
  });
  final bool isDelivered;
  final TripAndServiceModel? tripOrService;

  @override
  State<TripOrServiceItemWidget> createState() =>
      _TripOrServiceItemWidgetState();
}

class _TripOrServiceItemWidgetState extends State<TripOrServiceItemWidget> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserHomeCubit, UserHomeState>(
          listener: (context, state) {
            setState(() {}); // تحدث واجهة الرحلة عند أي تغيير في homeModel
          },
        ),
        BlocListener<UserTripAndServicesCubit, UserTripAndServicesState>(
          listener: (context, state) {
            setState(() {}); // تحديث ETA أو حالات الرحلة
          },
        ),
      ],
      child: BlocBuilder<UserTripAndServicesCubit, UserTripAndServicesState>(
        builder: (context, state) {
          final homeCubit = context.read<UserHomeCubit>();
          final trips = homeCubit.homeModel?.data?.trips ?? [];
          final trip = trips.firstWhere(
            (t) => t.id == widget.tripOrService!.id,
            orElse: () => widget.tripOrService!,
          );

          final bool hasDriver = trip.driver != null;
          final bool isCaptainArrived = trip.isDriverArrived == 1;
          final bool isTripStarted = trip.isUserStartTrip == 1;

          // ✅ Debug log
          log(
            "TRIP UI ==> id=${widget.tripOrService?.id} "
            "driver=${widget.tripOrService?.driver?.name} "
            "isDriverArrived=${widget.tripOrService?.isDriverArrived} "
            "isUserStartTrip=${widget.tripOrService?.isUserStartTrip} "
            "distance=${widget.tripOrService?.distance} "
            "driverDistance=${widget.tripOrService?.driverDistance}",
          );

          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.second4Primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.h.verticalSpace,
                  Row(
                    children: [
                      if (widget.tripOrService?.type == 'Schedule' ||
                          widget.tripOrService?.type == 'مجدولة')
                        Expanded(
                          child: Row(
                            children: [
                              MySvgWidget(path: AppIcons.date, height: 24.h),
                              10.w.horizontalSpace,
                              Flexible(
                                child: AutoSizeText(
                                  widget.tripOrService?.formattedDay ?? "--",
                                  maxLines: 1,
                                  style: getRegularStyle(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      10.w.horizontalSpace,
                      if (widget.tripOrService?.type == 'Schedule' ||
                          widget.tripOrService?.type == 'مجدولة')
                        Expanded(
                          child: Row(
                            children: [
                              MySvgWidget(
                                path: AppIcons.dateTime,
                                height: 24.h,
                              ),
                              10.w.horizontalSpace,
                              Flexible(
                                child: AutoSizeText(
                                  widget.tripOrService?.time ?? "--",
                                  maxLines: 1,
                                  style: getRegularStyle(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.tripOrService?.type == 'Type Now' ||
                          widget.tripOrService?.type == 'فورية')
                        Flexible(fit: FlexFit.tight, child: Container()),
                      GestureDetector(
                        onTap:
                            state is! LoadingChangeStatusOfTripAndServiceState
                            ? () {
                                context
                                    .read<UserTripAndServicesCubit>()
                                    .changeFavOfTripAndService(
                                      widget.tripOrService!,
                                    );
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.secondPrimary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: widget.tripOrService?.isFav == true
                                ? AppColors.primary
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.h.verticalSpace,
                  if (widget.tripOrService?.from != null ||
                      widget.tripOrService?.to != null)
                    CustomFromToWidget(
                      from: widget.tripOrService?.from ?? "غير محدد",
                      fromLat: widget.tripOrService?.fromLat,
                      fromLng: widget.tripOrService?.fromLong,
                      to: widget.tripOrService?.to ?? "غير محدد",
                      toLat: widget.tripOrService?.toLat,
                      toLng: widget.tripOrService?.toLong,
                      serviceTo: widget.tripOrService?.serviceToName,
                      isDriverAccepted:
                          trip.isDriverAccept ==
                          1, // ✅ true لو الكابتن قبل الرحلة
                      isDriverArrived:
                          trip.isDriverArrived == 1, // ✅ true لو الكابتن وصل
                    ),

                  // ✅ الشرط الثاني: الكابتن وصل
                  if (hasDriver && isCaptainArrived && !isTripStarted)
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18.sp,
                            color: Colors.green,
                          ),
                          5.w.horizontalSpace,
                          Text(
                            "الكابتن وصل",
                            style: getBoldStyle(
                              fontSize: 14.sp,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ✅ الشرط الثالث: الرحلة بدأت
                  if (isTripStarted)
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, bottom: 5.h),
                          child: CustomButton(
                            title: "تتبع مسار الرحلة",
                            height: 40.h,
                            fontSize: 14.sp,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserTrackingScreen(
                                    trip: widget.tripOrService!,
                                    mode:
                                        UserTrackingMode.toDestination, // ✅ صح
                                  ),
                                ),
                              );
                            },
                            btnColor: AppColors.primary,
                            textColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),

                  if (hasDriver)
                    CustomDriverInfo(
                      isCancelable: widget.tripOrService?.isUserStartTrip == 0,
                      onTapToCancelTrip: () {
                        warningDialog(
                          context,
                          btnOkText: 'confirm'.tr(),
                          title: 'are_you_sure_you_want_to_cancel_the_trip'
                              .tr(),
                          onPressedOk: () {
                            context.read<UserTripAndServicesCubit>().cancelTrip(
                              widget.tripOrService?.id.toString() ?? '',
                            );
                            context.read<UserHomeCubit>().getHome(context);
                          },
                        );
                      },
                      driver: widget.tripOrService?.driver,
                      roomToken: widget.tripOrService?.roomToken,
                      shipmentCode: widget.tripOrService?.code,
                      tripId: widget.tripOrService?.id?.toString() ?? '',
                      trip: widget.tripOrService,
                    )
                  else
                    Center(
                      child: Column(
                        children: [
                          CustomDivider(),
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    widget.tripOrService?.cannotFindDriver == 0
                                        ? 'searching_for_driver'.tr()
                                        : 'cannot_search_driver'.tr(),
                                    style: getRegularStyle(fontSize: 14.sp),
                                  ),
                                ),
                              ),
                              10.w.horizontalSpace,
                              Expanded(
                                child: CustomButton(
                                  title: widget.tripOrService?.isService == 1
                                      ? "cancel_service".tr()
                                      : "cancel_trip".tr(),
                                  height: 40.h,
                                  fontSize: 14.sp,
                                  onPressed: () {
                                    warningDialog(
                                      context,
                                      btnOkText: 'confirm'.tr(),
                                      title:
                                          'are_you_sure_you_want_to_cancel_the_trip'
                                              .tr(),
                                      onPressedOk: () {
                                        context
                                            .read<UserTripAndServicesCubit>()
                                            .cancelTrip(
                                              widget.tripOrService?.id
                                                      .toString() ??
                                                  '',
                                            );
                                        context.read<UserHomeCubit>().getHome(
                                          context,
                                        );
                                      },
                                    );
                                  },
                                  btnColor: AppColors.red,
                                  textColor: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
