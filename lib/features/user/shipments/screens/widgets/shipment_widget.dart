import 'package:waslny/core/exports.dart';

import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/shipments/screens/details/shipment_details_screen.dart';

import 'custom_driver_info.dart';
import 'custom_from_to.dart';

class ShipmentItemWidget extends StatelessWidget {
  const ShipmentItemWidget({
    super.key,
    this.isDelivered = false,
    this.shipment,
    // required this.shipment,
  });
  // final Shipment shipment;
  final bool isDelivered;
  final ShipmentModel? shipment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.userShipmentDetailsRoute,
          arguments: UserShipmentDetailsArgs(
              shipmentId: shipment?.id.toString() ?? ''),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
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
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
          horizontal: 15.w,
        ),
        child: isDelivered
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shipment?.code ?? "",
                      style: getMediumStyle(
                        fontSize: 16.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    Flexible(
                      child: AutoSizeText(
                        "${shipment?.day ?? "30/10/2023"}   |  ${shipment?.time ?? "10:00 AM"}",
                        maxLines: 1,
                        minFontSize: 10.sp,
                        style: getRegularStyle(
                          fontSize: 13.sp,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                10.h.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        flex: 3,
                        child: RichText(
                            text: TextSpan(
                          text: "${"goods_type".tr()} : ",
                          style: getMediumStyle(
                            fontSize: 14.sp,
                          ),
                          children: [
                            TextSpan(
                              text: shipment?.goodsType ?? " ",
                              style: getRegularStyle(
                                fontSize: 13.sp,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ))),
                    Flexible(
                      flex: 2,
                      child: RichText(
                          text: TextSpan(
                        text: "${"to".tr()} : ",
                        style: getMediumStyle(
                          fontSize: 14.sp,
                        ),
                        children: [
                          TextSpan(
                            text: shipment?.to ?? " ",
                            style: getRegularStyle(
                              fontSize: 13.sp,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${"code".tr()} ${shipment?.code ?? "code"}',
                    style: getMediumStyle(
                      fontSize: 16.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  10.h.verticalSpace,
                  Row(
                    children: [
                      MySvgWidget(
                        path: AppIcons.shipmentType,
                        height: 25.h,
                        width: 25.h,
                        // imageColor: AppColors.dark2Grey,
                      ),
                      10.w.horizontalSpace,
                      Text("${"goods_type".tr()} : ",
                          style: getMediumStyle(
                            fontSize: 14.sp,
                          )),
                      Flexible(
                        child: Text(
                          shipment?.goodsType ?? " ",
                          style: getRegularStyle(
                            fontSize: 13.sp,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.h.verticalSpace,
                  Row(
                    children: [
                      MySvgWidget(
                        path: AppIcons.date,
                        height: 24.h,
                        // imageColor: AppColors.secondPrimary,
                      ),
                      10.w.horizontalSpace,
                      Flexible(
                        child: AutoSizeText(
                          "${shipment?.day ?? "30/10/2023"}   |  ${shipment?.time ?? "10:00 AM"}",
                          maxLines: 1,
                          style: getRegularStyle(),
                        ),
                      ),
                    ],
                  ),
                  10.h.verticalSpace,
                  CustomFromToWidget(
                    from: shipment?.from,
                    to: shipment?.to,
                    fromLat: shipment?.lat,
                    fromLng: shipment?.long,
                  ),
                  if (shipment?.driver != null) ...[
                    CustomDriverInfo(
                      driver: shipment?.driver,
                      roomToken: null,
                      shipmentCode: shipment?.code,
                      shipmentId: shipment?.id?.toString() ?? '',
                    )
                  ]
                ],
              ),
      ),
    );
  }
}
