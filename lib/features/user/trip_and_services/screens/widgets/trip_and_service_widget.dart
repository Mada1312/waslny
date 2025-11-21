import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_divider.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';

import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/cubit/state.dart';

import 'custom_driver_info.dart';
import 'custom_from_to.dart';

class TripOrServiceItemWidget extends StatefulWidget {
  const TripOrServiceItemWidget({
    super.key,
    this.isDelivered = false,
    this.tripOrService,
    // required this.shipment,
  });
  // final Shipment shipment;
  final bool isDelivered;
  final TripAndServiceModel? tripOrService;

  @override
  State<TripOrServiceItemWidget> createState() =>
      _TripOrServiceItemWidgetState();
}

class _TripOrServiceItemWidgetState extends State<TripOrServiceItemWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserTripAndServicesCubit, UserTripAndServicesState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            // Navigator.pushNamed(
            //   context,
            //   Routes.userShipmentDetailsRoute,
            //   arguments: UserShipmentDetailsArgs(
            //     shipmentId: tripOrService?.id.toString() ?? '',
            //   ),
            // );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.second4Primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
            child:
                /*isDelivered
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       tripOrService?.code ?? "",
                      //       style: getMediumStyle(
                      //         fontSize: 16.sp,
                      //         color: AppColors.primary,
                      //       ),
                      //     ),
                      //     Flexible(
                      //       child: AutoSizeText(
                      //         "${tripOrService?.day ?? "30/10/2023"}   |  ${tripOrService?.time ?? "10:00 AM"}",
                      //         maxLines: 1,
                      //         minFontSize: 10.sp,
                      //         style: getRegularStyle(
                      //           fontSize: 13.sp,
                      //           color: AppColors.darkGrey,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // 10.h.verticalSpace,
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Flexible(
                      //       flex: 3,
                      //       child: RichText(
                      //         text: TextSpan(
                      //           text: "${"goods_type".tr()} : ",
                      //           style: getMediumStyle(fontSize: 14.sp),
                      //           children: [
                      //             TextSpan(
                      //               text: tripOrService?.goodsType ?? " ",
                      //               style: getRegularStyle(
                      //                 fontSize: 13.sp,
                      //                 color: AppColors.darkGrey,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //     Flexible(
                      //       flex: 2,
                      //       child: RichText(
                      //         text: TextSpan(
                      //           text: "${"to".tr()} : ",
                      //           style: getMediumStyle(fontSize: 14.sp),
                      //           children: [
                      //             TextSpan(
                      //               text: tripOrService?.to ?? " ",
                      //               style: getRegularStyle(
                      //                 fontSize: 13.sp,
                      //                 color: AppColors.darkGrey,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  )
                :*/
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   '${"code".tr()} ${tripOrService?.code ?? "code"}',
                    //   style: getMediumStyle(
                    //     fontSize: 16.sp,
                    //     color: AppColors.primary,
                    //   ),
                    // ),
                    10.h.verticalSpace,
                    Row(
                      children: [
                        if (widget.tripOrService?.type == 'Schedule' ||
                            widget.tripOrService?.type == 'مجدولة')
                          Expanded(
                            child: Row(
                              children: [
                                MySvgWidget(
                                  path: AppIcons.date,
                                  height: 24.h,
                                  // imageColor: AppColors.secondPrimary,
                                ),
                                10.w.horizontalSpace,
                                Flexible(
                                  child: AutoSizeText(
                                    DateFormat('yyyy-MM-dd').format(
                                      widget.tripOrService?.day ??
                                          DateTime.now(),
                                    ),

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
                                  // imageColor: AppColors.secondPrimary,
                                ),
                                10.w.horizontalSpace,
                                Flexible(
                                  child: AutoSizeText(
                                    widget.tripOrService?.time ?? '',

                                    maxLines: 1,
                                    style: getRegularStyle(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.tripOrService?.type == 'Type Now' ||
                            widget.tripOrService?.type == 'فورية')
                          Flexible(
                            fit: FlexFit.tight,
                            child: Container(),
                            //  Text(
                            //   widget.tripOrService?.type ?? '',
                            //   style: getRegularStyle(
                            //     color: AppColors.primary,
                            //   ),
                            // ),
                          ),
                        GestureDetector(
                          onTap: () {
                            if (state
                                is! LoadingChangeStatusOfTripAndServiceState) {
                              context
                                  .read<UserTripAndServicesCubit>()
                                  .changeFavOfTripAndService(
                                    widget.tripOrService!,
                                  );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
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
                    CustomFromToWidget(
                      from: widget.tripOrService?.from,
                      fromLat: widget.tripOrService?.fromLat,
                      fromLng: widget.tripOrService?.fromLong,
                      to: widget.tripOrService?.to,
                      toLat: widget.tripOrService?.toLat,
                      toLng: widget.tripOrService?.toLong,
                      serviceTo: widget.tripOrService?.serviceToName,
                    ),
                    if (widget.tripOrService?.distance.toString() != "")
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MySvgWidget(
                            path: AppIcons.fromMapIcon,
                            width: 25.sp,
                            height: 30.sp,
                            // imageColor: AppColors.dark2Grey,
                          ),
                          10.w.horizontalSpace,
                          Flexible(
                            child: Text(
                              "${((widget.tripOrService?.distance?.length ?? 0) > 4 ? (widget.tripOrService?.distance ?? '').substring(0, 4) : (widget.tripOrService?.distance ?? ''))} ${'km'.tr()}",
                              style: getMediumStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    (widget.tripOrService?.driver != null)
                        ? CustomDriverInfo(
                            isCancelable:
                                widget.tripOrService?.isUserStartTrip == 0,
                            onTapToCancelTrip: () {
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
                                        widget.tripOrService?.id.toString() ??
                                            '',
                                      );
                                  context.read<UserHomeCubit>().getHome(
                                    context,
                                  );
                                },
                              );
                            },
                            driver: widget.tripOrService?.driver,
                            roomToken: widget.tripOrService?.roomToken,
                            shipmentCode: widget.tripOrService?.code,
                            tripId: widget.tripOrService?.id?.toString() ?? '',
                            trip: widget.tripOrService,
                          )
                        : Center(
                            child: Column(
                              children: [
                                CustomDivider(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          widget
                                                      .tripOrService
                                                      ?.cannotFindDriver ==
                                                  0
                                              ? 'searching_for_driver'.tr()
                                              : 'cannot_search_driver'.tr(),
                                          style: getRegularStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    10.w.horizontalSpace,
                                    Expanded(
                                      child: CustomButton(
                                        title:
                                            widget.tripOrService?.isService == 1
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
                                                  .read<
                                                    UserTripAndServicesCubit
                                                  >()
                                                  .cancelTrip(
                                                    widget.tripOrService?.id
                                                            .toString() ??
                                                        '',
                                                  );
                                              context
                                                  .read<UserHomeCubit>()
                                                  .getHome(context);
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
    );
  }
}
