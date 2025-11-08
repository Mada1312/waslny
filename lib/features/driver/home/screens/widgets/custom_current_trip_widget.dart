import 'dart:developer' show log;

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/cubit/cubit.dart'
    show DriverHomeCubit;
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
// import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/call_message.dart';

class CustomsSheduledTripWidet extends StatelessWidget {
  const CustomsSheduledTripWidet({super.key, this.trip});
  final DriverTripModel? trip;
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();

    return SafeArea(
      top: false,
      // bottom: false,
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
              FromToContainer(
                isFrom: true,
                address: trip?.from,
                lat: trip?.fromLat,
                lng: trip?.fromLong,
              ),
              8.h.verticalSpace,
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

                  // if (trip?.description != "")
                  //   IconButton(
                  //     onPressed: () {
                  //       showDialog(
                  //         context: context,
                  //         builder: (BuildContext context) {
                  //           return AlertDialog(
                  //             insetPadding: const EdgeInsets.all(8),
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(10.r),
                  //             ),
                  //             title: Row(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 Text(
                  //                   "enter_trip_desc".tr(),
                  //                   style: TextStyle(
                  //                     fontSize: 18.sp,
                  //                     fontWeight: FontWeight.bold,
                  //                   ),
                  //                 ),
                  //                 InkWell(
                  //                   child: Icon(
                  //                     Icons.close,
                  //                     color: Colors.black,
                  //                   ),
                  //                   onTap: () => Navigator.pop(context),
                  //                 ),
                  //               ],
                  //             ),
                  //             content: Text(
                  //               trip?.description ?? '',
                  //               style: TextStyle(fontSize: 14.sp),
                  //             ),
                  //           );
                  //         },
                  //       );
                  //     },
                  //     icon: Icon(Icons.info, color: AppColors.secondPrimary),
                  //   ),
                ],
              ),
              if (trip?.distance != null && trip?.distance?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MySvgWidget(
                        path: AppIcons.fromMapIcon,
                        width: 30.sp,
                        height: 30.sp,
                        // imageColor: AppColors.dark2Grey,
                      ),
                      10.w.horizontalSpace,
                      Flexible(
                        child: Text(
                          "${(trip?.distance ?? '').substring(0, 4)} ${'km'.tr()}",
                          style: getMediumStyle(fontSize: 15.sp),
                        ),
                      ),
                    ],
                  ),
                ),
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
              Row(
                children: [
                  if (trip?.isDriverAccept == 0 &&
                      trip?.isDriverAnotherTrip == 0) ...[
                    Flexible(
                      // flex: 1,
                      child: CustomButton(
                        title: "accept".tr(),
                        onPressed: () {
                          warningDialog(
                            context,
                            title: "are_you_sure_you_want_to_accept_trip".tr(),
                            onPressedOk: () {
                              cubit.updateTripStatus(
                                id: trip?.id ?? 0,
                                step: TripStep.isDriverAccept,
                                context: context,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    10.w.horizontalSpace,
                  ],
                  if (trip?.status == 0 &&
                      trip?.isDriverArrived == 0 &&
                      trip?.isDriverAccept == 1 &&
                      trip?.isDriverAnotherTrip == 0) ...[
                    Flexible(
                      // flex: 1,
                      child: CustomButton(
                        title: "arrived".tr(),
                        btnColor: AppColors.secondPrimary,
                        textColor: AppColors.primary,
                        onPressed: () {
                          warningDialog(
                            context,
                            title: "are_you_sure_you_want_to_confirm_arrival"
                                .tr(),
                            onPressedOk: () {
                              cubit.updateTripStatus(
                                id: trip?.id ?? 0,
                                step: TripStep.isDriverArrived,
                                context: context,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    10.w.horizontalSpace,
                  ],
                  if (trip?.status == 0 &&
                      trip?.isDriverAccept == 1 &&
                      trip?.isDriverArrived == 1) ...[
                    Flexible(
                      child: CustomButton(
                        title: "start_trip".tr(),
                        isDisabled: trip?.isUserAccept == 0,
                        onPressed: () {
                          warningDialog(
                            context,
                            title: "are_you_sure_you_want_to_start_trip".tr(),
                            onPressedOk: () {
                              context.read<DriverHomeCubit>().startTrip(
                                tripId: trip?.id ?? 0,
                                context: context,
                              );
                            },
                          );
                        },
                        // btnColor: AppColors.secondPrimary,
                        // textColor: AppColors.primary,
                      ),
                    ),
                    10.w.horizontalSpace,
                  ],
                  if (trip?.status == 1 &&
                      trip?.isDriverAccept == 1 &&
                      trip?.isDriverArrived == 1) ...[
                    Flexible(
                      child: CustomButton(
                        title: "end_trip".tr(),
                        btnColor: AppColors.red,
                        textColor: AppColors.white,
                        isDisabled:
                            trip?.isService == 1 && trip?.isUserStartTrip == 0,
                        onPressed: () {
                          warningDialog(
                            context,
                            title: "are_you_sure_you_want_to_end_trip".tr(),
                            onPressedOk: () {
                              context.read<DriverHomeCubit>().endTrip(
                                tripId: trip?.id ?? 0,
                                context: context,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    10.w.horizontalSpace,
                  ],
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
