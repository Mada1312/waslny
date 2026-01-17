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

// import 'dart:developer' show log;
// import 'package:flutter/material.dart';
// import 'package:waslny/core/exports.dart';
// import 'package:waslny/core/utils/get_route_distance.dart';
// import 'package:waslny/features/driver/home/cubit/cubit.dart' show DriverHomeCubit;
// import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
// import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
// import 'package:waslny/features/general/location/cubit/location_cubit.dart';
// import 'package:waslny/features/general/navigation/navigation_screen.dart';
// import 'package:waslny/features/user/trip_and_services/screens/widgets/call_message.dart';

// class CustomsSheduledTripWidet extends StatelessWidget {
//   const CustomsSheduledTripWidet({super.key, this.trip});
//   final DriverTripModel? trip;

//   @override
//   Widget build(BuildContext context) {
//     var cubit = context.read<DriverHomeCubit>();

//     final fromLat = trip?.fromLat;
//     final fromLng = trip?.fromLong;
//     final toLat = trip?.toLat;
//     final toLng = trip?.toLong;

//     return SafeArea(
//       top: false,
//       child: Padding(
//         padding: EdgeInsets.only(top: 15.h),
//         child: Container(
//           decoration: BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(16.r),
//               topRight: Radius.circular(16.r),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.grey.withOpacity(0.3),
//                 blurRadius: 2,
//                 offset: const Offset(0, 3),
//               ),
//               BoxShadow(
//                 color: AppColors.grey.withOpacity(0.3),
//                 blurRadius: 2,
//                 offset: const Offset(0, -3),
//               ),
//             ],
//           ),
//           padding: EdgeInsets.all(15.sp),
//           child: Column(
//             children: [
//               FromToContainer(
//                 isFrom: true,
//                 address: trip?.from,
//                 lat: fromLat,
//                 lng: fromLng,
//               ),
//               8.h.verticalSpace,
//               Row(
//                 children: [
//                   Flexible(
//                     fit: FlexFit.tight,
//                     child: FromToContainer(
//                       isFrom: false,
//                       address: trip?.serviceToName ?? trip?.to,
//                       lat: toLat,
//                       lng: toLng,
//                       isService: trip?.isService == 1,
//                     ),
//                   ),
//                 ],
//               ),

//               // --------------------- المسافة بين الـ from و to ---------------------
//               if (fromLat != null && fromLng != null && toLat != null && toLng != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: FutureBuilder<double?>(
//                     future: getRouteDistance(
//                       double.parse(fromLat),
//                       double.parse(fromLng),
//                       double.parse(toLat),
//                       double.parse(toLng),
//                     ),
//                     builder: (context, snapshot) {
//                       String distanceText;
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         distanceText = "...".tr();
//                       } else if (snapshot.hasData) {
//                         distanceText = "${snapshot.data!.toStringAsFixed(2)} ${'km'.tr()}";
//                       } else {
//                         distanceText = "0.0 ${'km'.tr()}";
//                       }

//                       return Row(
//                         children: [
//                           MySvgWidget(
//                             path: AppIcons.fromMapIcon,
//                             width: 30.sp,
//                             height: 30.sp,
//                           ),
//                           10.w.horizontalSpace,
//                           Flexible(
//                             child: Text(
//                               distanceText,
//                               style: getMediumStyle(fontSize: 15.sp),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),

//               if (trip?.description != null && trip!.description!.isNotEmpty) ...[
//                 12.h.verticalSpace,
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.second3Primary,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   padding: EdgeInsets.all(12.sp),
//                   width: double.infinity,
//                   child: Text(
//                     trip?.description ?? "",
//                     style: getMediumStyle(fontSize: 12.sp),
//                   ),
//                 ),
//               ],

//               10.h.verticalSpace,

//               // -------------------- الأزرار كاملة --------------------
//               Row(
//                 children: [
//                   // زر قبول الرحلة
//                   if (trip?.isDriverAccept == 0 && trip?.isDriverAnotherTrip == 0) ...[
//                     Flexible(
//                       child: CustomButton(
//                         title: "accept".tr(),
//                         onPressed: () {
//                           if (trip?.isService == 1) {
//                             cubit.updateTripStatus(
//                               id: trip?.id ?? 0,
//                               step: TripStep.isDriverAccept,
//                               context: context,
//                             );
//                           } else {
//                             warningDialog(
//                               context,
//                               title: "are_you_sure_you_want_to_accept_trip".tr(),
//                               onPressedOk: () {
//                                 cubit.updateTripStatus(
//                                   id: trip?.id ?? 0,
//                                   step: TripStep.isDriverAccept,
//                                   context: context,
//                                 ).then((_) {
//                                   if (trip != null) {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => NavigationScreen(
//                                           currentTrip: trip!,
//                                           mode: NavigationTargetMode.toPickup,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 });
//                               },
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                     10.w.horizontalSpace,
//                   ],

//                   // زر الوصول للراكب
//                   if (trip?.isService == 0 &&
//                       trip?.isDriverArrived == 0 &&
//                       trip?.isDriverAccept == 1 &&
//                       trip?.isDriverAnotherTrip == 0) ...[
//                     Flexible(
//                       child: CustomButton(
//                         title: "arrived".tr(),
//                         btnColor: AppColors.secondPrimary,
//                         textColor: AppColors.primary,
//                         isDisabled: trip?.isUserAccept == 0,
//                         onPressed: () {
//                           cubit.updateTripStatus(
//                             id: trip?.id ?? 0,
//                             step: TripStep.isDriverArrived,
//                             context: context,
//                             receiverId: trip?.userId.toString(),
//                             chatId: trip?.roomToken,
//                           );
//                         },
//                       ),
//                     ),
//                     10.w.horizontalSpace,
//                   ],

//                   // زر بدء الرحلة أو الخدمة
//                   if (trip?.status == 0 &&
//                       trip?.isDriverAccept == 1 &&
//                       (trip?.isDriverArrived == 1 || trip?.isService == 1)) ...[
//                     Flexible(
//                       child: CustomButton(
//                         title: trip?.isService == 1 ? "start_service".tr() : "start_trip".tr(),
//                         isDisabled: trip?.isUserAccept == 0,
//                         onPressed: () {
//                           (trip?.isService == 1 ? cubit.startTrip(tripId: trip?.id ?? 0, context: context) : context.read<DriverHomeCubit>().startTrip(tripId: trip?.id ?? 0, context: context))
//                               .then((_) {
//                             if (trip != null) {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => NavigationScreen(
//                                     currentTrip: trip!,
//                                     mode: NavigationTargetMode.toDestination,
//                                   ),
//                                 ),
//                               );
//                             }
//                           });
//                         },
//                       ),
//                     ),
//                     10.w.horizontalSpace,
//                   ],

//                   // زر انهاء الرحلة أو الخدمة
//                   if (trip?.status == 1 &&
//                       trip?.isDriverAccept == 1 &&
//                       (trip?.isDriverArrived == 1 || trip?.isService == 1)) ...[
//                     Flexible(
//                       child: CustomButton(
//                         title: trip?.isService == 1 ? "end_service".tr() : "end_trip".tr(),
//                         btnColor: AppColors.red,
//                         textColor: AppColors.white,
//                         isDisabled: trip?.isService == 0 && trip?.isUserStartTrip == 0,
//                         onPressed: () {
//                           trip?.isService == 1
//                               ? cubit.endTrip(tripId: trip?.id ?? 0, context: context)
//                               : context.read<DriverHomeCubit>().endTrip(tripId: trip?.id ?? 0, context: context);
//                         },
//                       ),
//                     ),
//                     10.w.horizontalSpace,
//                   ],

//                   // زر رفض الرحلة
//                   if (trip?.isDriverAnotherTrip == 0)
//                     Flexible(
//                       child: CustomButton(
//                         title: "reject".tr(),
//                         btnColor: AppColors.secondPrimary,
//                         textColor: AppColors.primary,
//                         onPressed: () {
//                           warningDialog(
//                             context,
//                             title: "are_you_sure_you_want_to_decline_trip".tr(),
//                             onPressedOk: () {
//                               cubit.updateTripStatus(
//                                 id: trip?.id ?? 0,
//                                 step: TripStep.isDriverAnotherTrip,
//                                 context: context,
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   10.w.horizontalSpace,

//                   // زر الاتصال أو المراسلة
//                   CustomCallAndMessageWidget(
//                     tripId: trip?.id.toString() ?? '',
//                     driverId: trip?.driverId.toString(),
//                     receiverId: trip?.userId.toString(),
//                     isDriver: true,
//                     roomToken: trip?.roomToken,
//                     phoneNumber: trip?.user?.phone.toString(),
//                   ),
//                 ],
//               ),

//               80.h.verticalSpace,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --------------------- From / To Container ---------------------
// class FromToContainer extends StatelessWidget {
//   const FromToContainer({
//     super.key,
//     required this.isFrom,
//     this.address,
//     this.lat,
//     this.lng,
//     this.isService = false,
//   });
//   final bool isFrom;
//   final String? address;
//   final String? lat;
//   final String? lng;
//   final bool isService;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         log('lat: $lat, lng: $lng');
//         if (lat != null && lng != null) {
//           context.read<LocationCubit>().openGoogleMapsRoute(
//                 double.tryParse(lat!) ?? 0,
//                 double.tryParse(lng!) ?? 0,
//               );
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.secondPrimary,
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//         padding: EdgeInsets.all(12.sp),
//         width: double.infinity,
//         child: RichText(
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.start,
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: isFrom
//                     ? '${'from'.tr()}: '
//                     : isService
//                         ? '${'service_to'.tr()}: '
//                         : '${'to'.tr()}: ',
//                 style: getBoldStyle(fontSize: 16.sp, color: AppColors.primary),
//               ),
//               TextSpan(
//                 text: address ?? "",
//                 style: getMediumStyle(fontSize: 12.sp, color: AppColors.white),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
