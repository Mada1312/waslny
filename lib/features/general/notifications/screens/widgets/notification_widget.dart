import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/trips/screens/details/shipment_details_screen.dart';
import 'package:waslny/features/user/trip_and_services/screens/details/shipment_details_screen.dart';
import 'package:waslny/features/general/notifications/data/models/get_notifications_model.dart';
import 'package:waslny/features/main/cubit/cubit.dart';

class CustomNotificationCard extends StatelessWidget {
  const CustomNotificationCard({
    required this.notificationModel,
    super.key,
    required this.isDriver,
  });
  final NotificationModel notificationModel;
  final bool isDriver;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log(notificationModel.body.toString());
        log(notificationModel.referenceId.toString());
        // if (notificationModel.isSeen == 0) {
        //   notificationModel.isSeen = 1;
        //   context.read<NotificationsCubit>().markAsSeen(
        //         context,
        //         notificationId: notificationModel.id.toString(),
        //       );
        // }
        if (notificationModel.referenceTable == 'shipments') {
          if (isDriver) {
            if (notificationModel.isCurrent == 1) {
              context.read<MainCubit>().changeIndex(0);
            } else {
              if (notificationModel.hasShipment == 0) {
                Navigator.pushNamed(
                  context,
                  Routes.driverShipmentDetailsRoute,
                  arguments: DriverSHipmentsArgs(
                      shipmentId: notificationModel.referenceId.toString()),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "notification_details".tr(),
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      content: Text(
                        notificationModel.body ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    );
                  },
                );
              }
            }
          } else {
            Navigator.pushNamed(
              context,
              Routes.userShipmentDetailsRoute,
              arguments: UserShipmentDetailsArgs(
                shipmentId: notificationModel.referenceId.toString(),
              ),
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "notification_details".tr(),
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                content: Text(
                  notificationModel.body ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp),
                ),
              );
            },
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.menuContainer,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Image.asset(
              ImageAssets.logo,
              height: 50.h,
              width: 50.h,
              fit: BoxFit.cover,
              // color: AppColors.primary,
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notificationModel.title ?? '',
                          style: getBoldStyle(
                            // color: AppColors.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      5.horizontalSpace,
                      Text(
                        notificationModel.createdAt ?? '',
                        style: getBoldStyle(
                            color: AppColors.secondPrimary, fontSize: 12.sp),
                      ),
                    ],
                  ),
                  5.verticalSpace,
                  Text(
                    notificationModel.body ?? '',
                    style: getRegularStyle(
                      color: notificationModel.body != null &&
                              (notificationModel.body!.contains('قبول') ||
                                  notificationModel.body!.contains('accepted'))
                          ? AppColors.green
                          : AppColors.darkGrey,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//1024791856
