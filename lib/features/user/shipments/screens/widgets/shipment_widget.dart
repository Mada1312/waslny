import 'package:waslny/core/exports.dart';

import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/shipments/screens/details/shipment_details_screen.dart';

import 'custom_driver_info.dart';
import 'custom_from_to.dart';

class TripOrServiceItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                              DateFormat(
                                'yyyy-MM-dd',
                              ).format(tripOrService?.day ?? DateTime.now()),

                              maxLines: 1,
                              style: getRegularStyle(),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                              tripOrService?.time ?? '',

                              maxLines: 1,
                              style: getRegularStyle(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                10.h.verticalSpace,
                CustomFromToWidget(
                  from: tripOrService?.from,
                  to: tripOrService?.to,
                  fromLat: tripOrService?.toLat,
                  fromLng: tripOrService?.toLong,
                  toLat: tripOrService?.toLat,
                  toLng: tripOrService?.toLong,
                ),
                if (tripOrService?.driver != null) ...[
                  CustomDriverInfo(
                    driver: tripOrService?.driver,
                    roomToken: null,
                    shipmentCode: tripOrService?.code,
                    tripId: tripOrService?.id?.toString() ?? '',
                  ),
                ],
              ],
            ),
      ),
    );
  }
}
