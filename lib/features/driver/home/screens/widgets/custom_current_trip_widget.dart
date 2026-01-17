// import 'dart:developer' show log;

// import 'package:latlong2/latlong.dart' as ll;
// import 'package:waslny/core/exports.dart';
// import 'package:waslny/features/driver/home/cubit/cubit.dart'
//     show DriverHomeCubit;
// import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
// import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
// // import 'package:waslny/features/general/chat/screens/message_screen.dart';
// import 'package:waslny/features/general/location/cubit/location_cubit.dart';
// import 'package:waslny/features/general/navigation/navigation_screen.dart';
// import 'package:waslny/features/user/trip_and_services/screens/widgets/call_message.dart';

// class CustomsSheduledTripWidet extends StatelessWidget {
//   const CustomsSheduledTripWidet({super.key, this.trip});
//   final DriverTripModel? trip;
//   @override
//   Widget build(BuildContext context) {
//     var cubit = context.read<DriverHomeCubit>();

//     return SafeArea(
//       top: false,
//       // bottom: false,
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
//                 lat: trip?.fromLat,
//                 lng: trip?.fromLong,
//               ),
//               8.h.verticalSpace,
//               Row(
//                 children: [
//                   Flexible(
//                     fit: FlexFit.tight,
//                     child: FromToContainer(
//                       isFrom: false,
//                       address: trip?.serviceToName ?? trip?.to,
//                       lat: trip?.toLat,
//                       lng: trip?.toLong,
//                       isService: trip?.isService == 1,
//                     ),
//                   ),
//                 ],
//               ),
//               if (trip?.distance != null && trip?.distance?.isNotEmpty == true)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       MySvgWidget(
//                         path: AppIcons.fromMapIcon,
//                         width: 30.sp,
//                         height: 30.sp,
//                         // imageColor: AppColors.dark2Grey,
//                       ),
//                       10.w.horizontalSpace,
//                       Flexible(
//                         child: Text(
//                           "${((trip?.distance?.length ?? 0) > 4 ? (trip?.distance ?? '').substring(0, 4) : (trip?.distance ?? ''))} ${'km'.tr()}",

//                           style: getMediumStyle(fontSize: 15.sp),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               if (trip?.description != null &&
//                   trip!.description!.isNotEmpty) ...[
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
//               Row(
//                 children: [
//                   if (trip?.isDriverAccept == 0 &&
//                       trip?.isDriverAnotherTrip == 0) ...[
//                     Flexible(
//                       // flex: 1,
//                       child: CustomButton(
//                         title: "accept".tr(),
//                         onPressed: () {
//                           // ✅ لو خدمة → مباشرة يقبل (بدون navigation)
//                           if (trip?.isService == 1) {
//                             cubit.updateTripStatus(
//                               id: trip?.id ?? 0,
//                               step: TripStep.isDriverAccept,
//                               context: context,
//                             );
//                           }
//                           // ✅ لو رحلة عادية → warning dialog + navigation
//                           else {
//                             warningDialog(
//                               context,
//                               title: "are_you_sure_you_want_to_accept_trip"
//                                   .tr(),
//                               onPressedOk: () {
//                                 cubit
//                                     .updateTripStatus(
//                                       id: trip?.id ?? 0,
//                                       step: TripStep.isDriverAccept,
//                                       context: context,
//                                     )
//                                     .then((_) {
//                                       // ✅ Navigation تفتح **فقط** بعد الـ dialog + API success
//                                       final lat = double.tryParse(
//                                         trip?.fromLat ?? '',
//                                       );
//                                       final lng = double.tryParse(
//                                         trip?.fromLong ?? '',
//                                       );

//                                       if (lat == null || lng == null) {
//                                         log(
//                                           "Invalid pickup coords: fromLat=${trip?.fromLat}, fromLong=${trip?.fromLong}",
//                                         );
//                                         return;
//                                       }

//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => NavigationScreen(
//                                             destination: ll.LatLng(lat, lng),
//                                             mode: NavigationTargetMode.toPickup,
//                                             destinationName:
//                                                 trip?.from ?? "مكان العميل",
//                                           ),
//                                         ),
//                                       );
//                                     });
//                               },
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                     10.w.horizontalSpace,
//                   ],
//                   if (trip?.isService == 0 &&
//                       trip?.isDriverArrived == 0 &&
//                       trip?.isDriverAccept == 1 &&
//                       trip?.isDriverAnotherTrip == 0) ...[
//                     Flexible(
//                       child: CustomButton(
//                         title: trip?.isService == 1
//                             ? "start_service".tr()
//                             : "start_trip".tr(),
//                         isDisabled: trip?.isUserAccept == 0,
//                         onPressed: () {
//                           trip?.isService == 1
//                               ? cubit
//                                     .startTrip(
//                                       tripId: trip?.id ?? 0,
//                                       context: context,
//                                     )
//                                     .then((_) {
//                                       final lat = double.tryParse(
//                                         trip?.toLat ?? '',
//                                       );
//                                       final lng = double.tryParse(
//                                         trip?.toLong ?? '',
//                                       );

//                                       if (lat == null || lng == null) {
//                                         log("Invalid dropoff coords");
//                                         return;
//                                       }

//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => NavigationScreen(
//                                             destination: ll.LatLng(lat, lng),
//                                             mode:
//                                                 NavigationTargetMode.toDropoff,
//                                             destinationName:
//                                                 (trip?.serviceToName ??
//                                                     trip?.to) ??
//                                                 "الوجهة",
//                                           ),
//                                         ),
//                                       );
//                                     })
//                               : context
//                                     .read<DriverHomeCubit>()
//                                     .startTrip(
//                                       tripId: trip?.id ?? 0,
//                                       context: context,
//                                     )
//                                     .then((_) {
//                                       final lat = double.tryParse(
//                                         trip?.toLat ?? '',
//                                       );
//                                       final lng = double.tryParse(
//                                         trip?.toLong ?? '',
//                                       );

//                                       if (lat == null || lng == null) {
//                                         log("Invalid dropoff coords");
//                                         return;
//                                       }

//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => NavigationScreen(
//                                             destination: ll.LatLng(lat, lng),
//                                             mode:
//                                                 NavigationTargetMode.toDropoff,
//                                             destinationName:
//                                                 (trip?.serviceToName ??
//                                                     trip?.to) ??
//                                                 "الوجهة",
//                                           ),
//                                         ),
//                                       );
//                                     });
//                         },
//                       ),
//                     ),
//                     10.w.horizontalSpace,
//                   ],
//                   if (trip?.status == 1 &&
//                       trip?.isDriverAccept == 1 &&
//                       (trip?.isDriverArrived == 1 || trip?.isService == 1)) ...[
//                     Flexible(
//                       child: CustomButton(
//                         title: trip?.isService == 1
//                             ? "end_service".tr()
//                             : "end_trip".tr(),
//                         btnColor: AppColors.red,
//                         textColor: AppColors.white,
//                         isDisabled:
//                             trip?.isService == 0 && trip?.isUserStartTrip == 0,
//                         onPressed: () {
//                           trip?.isService == 1
//                               ? cubit.endTrip(
//                                   tripId: trip?.id ?? 0,
//                                   context: context,
//                                 )
//                               : context.read<DriverHomeCubit>().endTrip(
//                                   tripId: trip?.id ?? 0,
//                                   context: context,
//                                 );
//                         },
//                       ),
//                     ),
//                     10.w.horizontalSpace,
//                   ],

//                   if (trip?.status == 1 &&
//                       trip?.isDriverAccept == 1 &&
//                       (trip?.isDriverArrived == 1 || trip?.isService == 1)) ...[
//                     Flexible(
//                       child: CustomButton(
//                         title: trip?.isService == 1
//                             ? "end_service".tr()
//                             : "end_trip".tr(),
//                         btnColor: AppColors.red,
//                         textColor: AppColors.white,
//                         isDisabled:
//                             trip?.isService == 0 && trip?.isUserStartTrip == 0,
//                         onPressed: () {
//                           trip?.isService == 1
//                               ? cubit.endTrip(
//                                   tripId: trip?.id ?? 0,
//                                   context: context,
//                                 )
//                               : context.read<DriverHomeCubit>().endTrip(
//                                   tripId: trip?.id ?? 0,
//                                   context: context,
//                                 );
//                         },
//                       ),
//                     ),

//                     10.w.horizontalSpace,
//                   ],
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
//             double.tryParse(lat ?? '0') ?? 0,
//             double.tryParse(lng ?? '0') ?? 0,
//           );
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
//                     ? '${'service_to'.tr()}: '
//                     : '${'to'.tr()}: ',
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

import 'dart:developer' show log;
import 'package:latlong2/latlong.dart' as ll;
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/cubit/cubit.dart'
    show DriverHomeCubit;
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/navigation/navigation_screen.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/call_message.dart';

class CustomsSheduledTripWidet extends StatelessWidget {
  const CustomsSheduledTripWidet({super.key, this.trip});
  final DriverTripModel? trip;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    final actionTitle = _getActionButtonTitle(trip);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(top: 15.h),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: AppColors.grey.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: EdgeInsets.all(15.sp),
          child: Column(
            children: [
              // From
              FromToContainer(
                isFrom: true,
                address: trip?.from,
                lat: trip?.fromLat,
                lng: trip?.fromLong,
              ),
              8.h.verticalSpace,

              // To
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: FromToContainer(
                      isFrom: false,
                      address: trip?.serviceToName ?? trip?.to,
                      lat: trip?.toLat,
                      lng: trip?.toLong,
                      isService: trip?.isService == 1,
                    ),
                  ),
                ],
              ),

              // Distance
              if ((trip?.distance?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MySvgWidget(
                        path: AppIcons.fromMapIcon,
                        width: 30.sp,
                        height: 30.sp,
                      ),
                      10.w.horizontalSpace,
                      Flexible(
                        child: Text(
                          "${((trip?.distance?.length ?? 0) > 4 ? trip?.distance?.substring(0, 4) : trip?.distance ?? '')} ${'km'.tr()}",
                          style: getMediumStyle(fontSize: 15.sp),
                        ),
                      ),
                    ],
                  ),
                ),

              // Description
              if (trip?.description != null &&
                  trip!.description!.isNotEmpty) ...[
                12.h.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.second3Primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.all(12.sp),
                  width: double.infinity,
                  child: Text(
                    trip?.description ?? "",
                    style: getMediumStyle(fontSize: 12.sp),
                  ),
                ),
              ],

              10.h.verticalSpace,

              // Buttons Row
              Row(
                children: [
                  // Accept
                  if (trip?.isDriverAccept == 0 &&
                      trip?.isDriverAnotherTrip == 0)
                    Flexible(
                      child: CustomButton(
                        title: "accept".tr(),
                        onPressed: () {
                          if (trip?.isService == 1) {
                            cubit.updateTripStatus(
                              id: trip?.id ?? 0,
                              step: TripStep.isDriverAccept,
                              context: context,
                            );
                          } else {
                            warningDialog(
                              context,
                              title: "are_you_sure_you_want_to_accept_trip"
                                  .tr(),
                              onPressedOk: () {
                                cubit
                                    .updateTripStatus(
                                      id: trip?.id ?? 0,
                                      step: TripStep.isDriverAccept,
                                      context: context,
                                    )
                                    .then((_) {
                                      _navigateToPickup(context, trip);
                                    });
                              },
                            );
                          }
                        },
                      ),
                    ),
                  10.w.horizontalSpace,

                  // Start Trip / Start Service / Arrived
                  if (trip?.isDriverAccept == 1 &&
                      trip?.isDriverAnotherTrip == 0 &&
                      actionTitle.isNotEmpty) // ✅ الشرط الجديد
                    Flexible(
                      child: CustomButton(
                        title: actionTitle, // ✅ نستخدم المتغيّر
                        isDisabled: trip?.isUserAccept == 0,
                        onPressed: () {
                          _handleStartOrArrive(context, cubit, trip);
                        },
                      ),
                    ),

                  10.w.horizontalSpace,

                  if (trip?.status == 1 && trip?.isDriverAccept == 1)
                    Flexible(
                      child: CustomButton(
                        title: trip?.isService == 1
                            ? "end_service".tr()
                            : "end_trip".tr(),
                        btnColor: AppColors.red,
                        textColor: AppColors.white,
                        isDisabled:
                            trip?.isService == 0 && trip?.isUserStartTrip == 0,
                        onPressed: () {
                          trip?.isService == 1
                              ? cubit.endTrip(
                                  tripId: trip?.id ?? 0,
                                  context: context,
                                )
                              : cubit.endTrip(
                                  tripId: trip?.id ?? 0,
                                  context: context,
                                );
                        },
                      ),
                    ),
                  10.w.horizontalSpace,

                  // Reject
                  if (trip?.isDriverAnotherTrip == 0)
                    Flexible(
                      child: CustomButton(
                        title: "reject".tr(),
                        btnColor: AppColors.secondPrimary,
                        textColor: AppColors.primary,
                        onPressed: () {
                          warningDialog(
                            context,
                            title: "are_you_sure_you_want_to_decline_trip".tr(),
                            onPressedOk: () {
                              cubit.updateTripStatus(
                                id: trip?.id ?? 0,
                                step: TripStep.isDriverAnotherTrip,
                                context: context,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  10.w.horizontalSpace,

                  // Call & Message
                  CustomCallAndMessageWidget(
                    tripId: trip?.id.toString() ?? '',
                    driverId: trip?.driverId.toString(),
                    receiverId: trip?.userId.toString(),
                    isDriver: true,
                    roomToken: trip?.roomToken,
                    phoneNumber: trip?.user?.phone.toString(),
                  ),
                ],
              ),
              80.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  String _getActionButtonTitle(DriverTripModel? trip) {
    if (trip == null) return '';
    if (trip.isService == 1 && trip.isDriverArrived == 0)
      return "start_service".tr();
    if (trip.isService == 0 && trip.isDriverArrived == 0) return "arrived".tr();
    if (trip.isDriverStartTrip == 0) return "start_trip".tr();
    return '';
  }

  void _handleStartOrArrive(
    BuildContext context,
    DriverHomeCubit cubit,
    DriverTripModel? trip,
  ) {
    if (trip == null) return;

    log(
      "Action Button Pressed: tripId=${trip.id}, isService=${trip.isService}",
    );

    if (trip.isService == 1 && trip.isDriverArrived == 0) {
      cubit.startTrip(tripId: trip.id ?? 0, context: context);
      return;
    }

    if (trip.isService == 0 && trip.isDriverArrived == 0) {
      // زر وصلت → يحدث API وصول الكابتن
      cubit
          .updateTripStatus(
            id: trip.id ?? 0,
            step: TripStep.isDriverArrived,
            context: context,
          )
          .then((_) => _navigateToPickup(context, trip));
      return;
    }

    if (trip.isDriverStartTrip == 0) {
      cubit.startTrip(tripId: trip.id ?? 0, context: context).then((_) {
        _navigateToDropoff(context, trip);
      });
    }
  }

  void _navigateToPickup(BuildContext context, DriverTripModel? trip) {
    final lat = double.tryParse(trip?.fromLat ?? '');
    final lng = double.tryParse(trip?.fromLong ?? '');
    if (lat != null && lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NavigationScreen(
            destination: ll.LatLng(lat, lng),
            mode: NavigationTargetMode.toPickup,
            destinationName: trip?.from ?? "مكان العميل",
          ),
        ),
      );
    } else {
      log("Invalid pickup coords: ${trip?.fromLat}, ${trip?.fromLong}");
    }
  }

  void _navigateToDropoff(BuildContext context, DriverTripModel? trip) {
    final lat = double.tryParse(trip?.toLat ?? '');
    final lng = double.tryParse(trip?.toLong ?? '');
    if (lat != null && lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NavigationScreen(
            destination: ll.LatLng(lat, lng),
            mode: NavigationTargetMode.toDropoff,
            destinationName: trip?.serviceToName ?? trip?.to ?? "الوجهة",
          ),
        ),
      );
    } else {
      log("Invalid dropoff coords: ${trip?.toLat}, ${trip?.toLong}");
    }
  }
}

class FromToContainer extends StatelessWidget {
  const FromToContainer({
    super.key,
    required this.isFrom,
    this.address,
    this.lat,
    this.lng,
    this.isService = false,
  });
  final bool isFrom;
  final String? address;
  final String? lat;
  final String? lng;
  final bool isService;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log('lat: $lat, lng: $lng');
        if (lat != null && lng != null) {
          context.read<LocationCubit>().openGoogleMapsRoute(
            double.tryParse(lat ?? '0') ?? 0,
            double.tryParse(lng ?? '0') ?? 0,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondPrimary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.all(12.sp),
        width: double.infinity,
        child: RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          text: TextSpan(
            children: [
              TextSpan(
                text: isFrom
                    ? '${'from'.tr()}: '
                    : isService
                    ? '${'service_to'.tr()}: '
                    : '${'to'.tr()}: ',
                style: getBoldStyle(fontSize: 16.sp, color: AppColors.primary),
              ),
              TextSpan(
                text: address ?? "",
                style: getMediumStyle(fontSize: 12.sp, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
