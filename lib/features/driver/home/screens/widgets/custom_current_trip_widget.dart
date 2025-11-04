import 'dart:developer' show log;

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/cubit/cubit.dart'
    show DriverHomeCubit;
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';

class CustomsSheduledTripWidet extends StatelessWidget {
  const CustomsSheduledTripWidet({super.key, this.trip});
  final DriverTripModel? trip;
  @override
  Widget build(BuildContext context) {
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
              FromToContainer(
                isFrom: false,
                address:trip?.serviceToName?? trip?.to,
                lat: trip?.toLat,
                lng: trip?.toLong,
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
              20.h.verticalSpace,
              // show chat and reject if status == 0 (new) && isDriverAccept == 0 (not accepted)  || isUserAccept == 0 (not accepted)
              // show start trip button if status == 0 (new) & isDriverAccept == 1 (accepted) & isUserAccept == 1 (accepted)
              // show end trip button if status == 1 (in progress)
              trip?.status == 0 &&
                      (trip?.isDriverAccept == 0 || trip?.isUserAccept == 0)
                  ? Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: CustomButton(
                            title: "chat_with_client".tr(),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    model: MainUserAndRoomChatModel(
                                      driverId: trip?.driverId.toString(),
                                      receiverId: trip?.userId.toString(),
                                      tripId: trip?.id.toString(),
                                      chatId: trip?.roomToken,
                                      isDriver: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        20.w.horizontalSpace,
                        Flexible(
                          flex: 1,
                          child: CustomButton(
                            title: "reject".tr(),
                            btnColor: AppColors.secondPrimary,
                            textColor: AppColors.primary,
                            onPressed: () {
                              warningDialog(
                                context,
                                title: "are_you_sure_you_want_to_reject_trip"
                                    .tr(),
                                onPressedOk: () {
                                  context.read<DriverHomeCubit>().cancleTrip(
                                    tripId: trip?.id ?? 0,
                                    context: context,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : trip?.status == 0 &&
                        trip?.isDriverAccept == 1 &&
                        trip?.isUserAccept == 1
                  ? CustomButton(
                      title: "start_trip".tr(),
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
                    )
                  : trip?.status == 1 &&
                        trip?.isDriverAccept == 1 &&
                        trip?.isUserAccept == 1 &&
                        trip?.isDriverStartTrip == 1 &&
                        trip?.isUserStartTrip == 1
                  ? CustomButton(
                      title: "end_trip".tr(),
                      btnColor: AppColors.red,
                      textColor: AppColors.white,
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
                    )
                  : Container(),

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
  });
  final bool isFrom;
  final String? address;
  final String? lat;
  final String? lng;

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
                text: isFrom ? '${'from'.tr()}: ' : '${'to'.tr()}: ',
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
