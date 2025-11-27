import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/my_svg_widget.dart';
import 'package:waslny/features/driver/trips/data/models/shipment_details_model.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';

class FollowShipmentWidget extends StatelessWidget {
  const FollowShipmentWidget({
    super.key,
    this.shipmentTracking,
  });
  final List<ShipmentTracking>? shipmentTracking;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "shipment_tracking_system".tr(),
        style: getMediumStyle(
          fontSize: 16.sp,
        ),
      ),
      20.h.verticalSpace,
      if (shipmentTracking == null || shipmentTracking!.isEmpty)
        Center(
          child: CustomNoDataWidget(
            message: "no_tracking_data".tr(),
          ),
        )
      else ...[
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      MySvgWidget(
                        path:
                            index == 0 ? AppIcons.from : AppIcons.shipmentType,
                        height: 20.h,
                        width: 20.h,
                        imageColor: index == 0 ? AppColors.dark2Grey : null,
                      ),
                      5.h.verticalSpace,
                      Expanded(
                          child: Column(
                        children: List.generate(
                          5,
                          (index) => Expanded(
                            child: Container(
                              width: 2.w,
                              color: index % 2 == 0
                                  ? AppColors.secondPrimary
                                  : AppColors.white,
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                  10.w.horizontalSpace,
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipmentTracking?[index].createdAt ?? "date",
                          style: getMediumStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                        10.h.verticalSpace,
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: 5,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              log("onTap");
                              log(shipmentTracking?[index].lat.toString() ??
                                  "null");
                              log(shipmentTracking?[index].long.toString() ??
                                  "null");
                              if (shipmentTracking?[index].lat == null ||
                                  shipmentTracking?[index].long == null) {
                                return;
                              }
                              double destinationLat = double.parse(
                                  shipmentTracking?[index].lat?.toString() ??
                                      "0");
                              double destinationLng = double.parse(
                                  shipmentTracking?[index].long?.toString() ??
                                      "0");
                              context.read<LocationCubit>().openGoogleMapsRoute(
                                  destinationLat, destinationLng);
                            },
                            child: Container(
                              decoration: BoxDecoration(
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
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 10.w,
                              ),
                              child: Row(
                                children: [
                                  MySvgWidget(
                                    path: AppIcons.location,
                                    height: 20.h,
                                    width: 20.h,
                                    imageColor: AppColors.dark2Grey,
                                  ),
                                  10.w.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      shipmentTracking?[index].location ??
                                          "location",
                                      style: getRegularStyle(
                                        fontSize: 14.sp,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        30.h.verticalSpace,
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: shipmentTracking?.length ?? 0,
        ),
        MySvgWidget(
          path: AppIcons.shipmentType,
          height: 20.h,
          width: 20.h,
          // imageColor: null,
        ),
      ]
    ]);
  }
}
