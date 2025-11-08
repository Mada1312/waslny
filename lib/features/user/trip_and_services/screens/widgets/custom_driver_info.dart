import 'dart:developer';

import 'package:waslny/core/exports.dart';

import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
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
        CustomDriverCardInfo(
          driver: widget.driver,
          shipmentCode: widget.shipmentCode,
          tripId: widget.tripId,
        ),

        10.w.horizontalSpace,
        Row(
          children: [
            if (widget.trip?.isUserAccept == 0) ...[
              Flexible(
                flex: 3,
                child: CustomButton(
                  title: "accept_trip".tr(),
                  height: 40.h,
                  fontSize: 14.sp,

                  onPressed: () {
                    warningDialog(
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
                  title: "start_trip".tr(),
                  height: 40.h,
                  fontSize: 14.sp,

                  isDisabled: widget.trip?.isDriverAccept == 0,
                  onPressed: () {
                    warningDialog(
                      context,
                      title: "are_you_sure_you_want_to_start_trip".tr(),
                      onPressedOk: () {
                        cubit.updateTripStatus(
                          id: widget.trip?.id ?? 0,
                          step: TripStep.isUserStartTrip,
                          context: context,
                        );
                      },
                    );
                  },
                ),
              ),
              10.w.horizontalSpace,
            ],
            if (widget.trip?.isUserChangeCaptain == 0)
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
            // !widget.isCancelable
            //     ? SizedBox()
            //     :
            Expanded(
              child: CustomButton(
                title: "cancel_trip".tr(),
                onPressed: widget.onTapToCancelTrip,
                height: 40.h,
                fontSize: 14.sp,
                btnColor: AppColors.red,
                textColor: AppColors.white,
              ),
            ),
            20.h.horizontalSpace,
            CustomCallAndMessageWidget(
              driverId:
                  widget.driver?.id?.toString() ??
                  widget.driver?.id?.toString(),
              name: widget.driver?.name ?? '',
              tripId: widget.tripId,
              roomToken: widget.roomToken,
              shipmentCode: widget.shipmentCode,
              phoneNumber: widget.driver?.phone.toString(),
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
