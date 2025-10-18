import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/my_svg_widget.dart';
import 'package:waslny/features/user/trip_and_services/data/models/shipment_details.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/custom_from_to.dart';

class ShipmentDetailsUserBody extends StatelessWidget {
  const ShipmentDetailsUserBody({super.key, this.shipmentData});
  final UserShipmentData? shipmentData;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${"code".tr()} ${shipmentData?.code ?? ""}',
          style: getMediumStyle(fontSize: 16.sp, color: AppColors.primary),
        ),
        20.h.verticalSpace,
        CustomFromToWidget(
          from: shipmentData?.from,
          to: shipmentData?.to?.name,
          fromLat: shipmentData?.lat,
          toLat: null,
          toLng: null,
          fromLng: shipmentData?.long,
        ),
        10.h.verticalSpace,
        Divider(color: AppColors.grey.withOpacity(0.3), height: 1),
        30.h.verticalSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShipmentInfo(
              title: 'shipment_type'.tr(),
              value: shipmentData?.truckType?.name ?? "نوع الشحنة",
              icon: AppIcons.shipmentType,
            ),
            20.w.horizontalSpace,
            ShipmentInfo(
              title: 'cargo_volume'.tr(),
              value: "${shipmentData?.size} ${"tons".tr()}",
              icon: AppIcons.shipmentSize,
            ),
          ],
        ),
        20.h.verticalSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShipmentInfo(
              title: 'date'.tr(),
              value: shipmentData?.day ?? "date",
              icon: AppIcons.date,
            ),
            20.w.horizontalSpace,
            ShipmentInfo(
              title: 'time'.tr(),
              value: shipmentData?.time ?? "time",
              icon: AppIcons.time,
            ),
          ],
        ),
        20.h.verticalSpace,
        Divider(color: AppColors.grey.withOpacity(0.3), height: 1),
        30.h.verticalSpace,
        Text("goods_type".tr(), style: getMediumStyle(fontSize: 16.sp)),
        10.h.verticalSpace,
        Text(
          "    ${shipmentData?.goodsType ?? "نوع "}",
          style: getRegularStyle(fontSize: 16.sp, color: AppColors.darkGrey),
        ),
        20.h.verticalSpace,
        Text("trip_details".tr(), style: getMediumStyle(fontSize: 16.sp)),
        10.h.verticalSpace,
        Text(
          "    ${shipmentData?.description ?? "وصف الرحلة"}",
          style: getRegularStyle(fontSize: 16.sp, color: AppColors.darkGrey),
        ),
      ],
    );
  }
}

class ShipmentInfo extends StatelessWidget {
  const ShipmentInfo({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MySvgWidget(path: icon, height: 25.h, width: 25.h),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: getMediumStyle(fontSize: 14.sp)),
                5.h.verticalSpace,
                Text(
                  value,
                  style: getRegularStyle(
                    fontSize: 16.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
