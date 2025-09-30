import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/driver/shipments/screens/details/shipment_details_screen.dart';
import 'package:waslny/features/user/shipments/screens/widgets/custom_from_to.dart';

import 'custom_user_info.dart';

// import 'custom_exporter_info.dart';

class DriverShipmentItemWidget extends StatelessWidget {
  const DriverShipmentItemWidget({
    super.key,
    required this.withContactWidget,
    this.shipment,
  });
  // final Shipment shipment;

  final bool withContactWidget;
  final ShipmentDriverModel? shipment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.driverShipmentDetailsRoute,
          arguments: DriverSHipmentsArgs(
            shipmentId: shipment?.id.toString(),
          ),
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
          vertical: 15.h,
          horizontal: 15.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${"code".tr()} ${shipment?.code ?? ""}',
              style: getMediumStyle(
                fontSize: 16.sp,
                color: AppColors.primary,
              ),
            ),
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
                  // imageColor: AppColors.dark2Grey,
                ),
                10.w.horizontalSpace,
                Flexible(
                  child: Text(
                    "${formatDate(shipment?.shipmentDateTime) ?? "30/10/2023"}  |  ${formatTime(shipment?.shipmentDateTime) ?? "10:00 AM"}",
                    style: getRegularStyle(),
                  ),
                ),
              ],
            ),
            10.h.verticalSpace,
            CustomFromToWidget(
              from: shipment?.from,
              to: shipment?.toCountry?.name,
              fromLat: shipment?.lat,
              fromLng: shipment?.long,
            ),
            10.h.verticalSpace,
            CustomTheUserInfo(
              inProgress: shipment?.driverStatus == 0,
              withContactWidget: withContactWidget,
              exporter: shipment?.user,
              roomToken: shipment?.roomToken,
              driverId: null,
              shipmentCode: shipment?.code,
              shipmentId: shipment?.id.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
