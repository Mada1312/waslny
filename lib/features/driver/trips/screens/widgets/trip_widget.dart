import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/driver/trips/screens/details/shipment_details_screen.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/custom_from_to.dart';

import 'custom_user_info.dart';

// import 'custom_exporter_info.dart';

class DriverTripPrServiceItemWidget extends StatelessWidget {
  const DriverTripPrServiceItemWidget({
    super.key,
    required this.withContactWidget,
    this.trip,
  });
  // final Shipment shipment;

  final bool withContactWidget;
  final DriverTripModel? trip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.driverShipmentDetailsRoute,
          arguments: DriverSHipmentsArgs(shipmentId: trip?.id.toString()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.second2Primary,
          borderRadius: BorderRadius.circular(10.r),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColors.grey.withOpacity(0.3),
          //     blurRadius: 2,
          //     offset: const Offset(0, 3),
          //   ),
          //   BoxShadow(
          //     color: AppColors.grey.withOpacity(0.3),
          //     blurRadius: 2,
          //     offset: const Offset(0, -3),
          //   ),
          // ],
        ),
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          trip?.day ?? "",

                          maxLines: 1,
                          style: getRegularStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
                10.w.horizontalSpace,

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
                          trip?.time ?? "",

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
              from: trip?.from,
              to: trip?.to,
              fromLat: trip?.fromLat,
              fromLng: trip?.fromLong,
              toLat: trip?.toLat,
              toLng: trip?.toLong,
            ),
            // 10.h.verticalSpace,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "chat".tr(),
                        style: getRegularStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "cancel_trip".tr(),
                        style: getRegularStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // CustomTheUserInfo(
            //   inProgress: trip?.driverStatus == 0,
            //   withContactWidget: withContactWidget,
            //   exporter: trip?.user,
            //   roomToken: trip?.roomToken,
            //   driverId: null,
            //   shipmentCode: trip?.code,
            //   tripId: trip?.id.toString(),
            // ),
          ],
        
        ),
      ),
    );
  }
}
