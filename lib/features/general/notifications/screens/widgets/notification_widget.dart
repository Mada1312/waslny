import 'dart:developer';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/notifications/data/models/get_notifications_model.dart';
import 'package:waslny/features/main/cubit/cubit.dart';

// import 'package:intl/intl.dart';
class NotificationsListView extends StatelessWidget {
  const NotificationsListView({
    required this.notifications,
    required this.isDriver,
    super.key,
  });

  final List<NotificationModel> notifications;
  final bool isDriver;

  Map<String, List<NotificationModel>> _groupNotificationsByDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    Map<String, List<NotificationModel>> grouped = {
      'today': [],
      'yesterday': [],
      'past': [],
    };

    for (var notification in notifications) {
      if (notification.createdAt == null) {
        grouped['past']!.add(notification);
        continue;
      }

      try {
        // Parse the date string format: "2025/10/25 09:32 PM"
        DateTime notificationDate = _parseCustomDate(notification.createdAt!);

        final dateOnly = DateTime(
          notificationDate.year,
          notificationDate.month,
          notificationDate.day,
        );

        if (dateOnly.isAtSameMomentAs(today)) {
          grouped['today']!.add(notification);
        } else if (dateOnly.isAtSameMomentAs(yesterday)) {
          grouped['yesterday']!.add(notification);
        } else {
          grouped['past']!.add(notification);
        }
      } catch (e) {
        grouped['past']!.add(notification);
      }
    }

    return grouped;
  }

  DateTime _parseCustomDate(String dateStr) {
    try {
      // Format: "2025/10/25 09:32 PM"
      final parts = dateStr.split(' ');
      final dateParts = parts[0].split('/');
      final timeParts = parts[1].split(':');
      final isPM = parts[2].toUpperCase() == 'PM';

      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Convert to 24-hour format
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotificationsByDate();

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 10.h,
      ).copyWith(bottom: (kBottomNavigationBarHeight + 5).h),
      children: [
        if (groupedNotifications['today']!.isNotEmpty) ...[
          _buildSectionHeader(context, 'today'.tr()),
          10.verticalSpace,
          _buildNotificationGroup(context, groupedNotifications['today']!),
          20.verticalSpace,
        ],
        if (groupedNotifications['yesterday']!.isNotEmpty) ...[
          _buildSectionHeader(context, 'yesterday'.tr()),
          10.verticalSpace,
          _buildNotificationGroup(context, groupedNotifications['yesterday']!),
          20.verticalSpace,
        ],
        if (groupedNotifications['past']!.isNotEmpty) ...[
          _buildSectionHeader(context, 'past'.tr()),
          10.verticalSpace,
          _buildNotificationGroup(context, groupedNotifications['past']!),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: getBoldStyle(color: AppColors.darkGrey, fontSize: 16.sp),
      ),
    );
  }

  Widget _buildNotificationGroup(
    BuildContext context,
    List<NotificationModel> notifications,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(notifications.length, (index) {
          final isFirst = index == 0;
          final isLast = index == notifications.length - 1;

          return CustomNotificationCard(
            notificationModel: notifications[index],
            isDriver: isDriver,
            isFirst: isFirst,
            isLast: isLast,
          );
        }),
      ),
    );
  }
}

// ==================== notification_widget.dart ====================

class CustomNotificationCard extends StatelessWidget {
  const CustomNotificationCard({
    required this.notificationModel,
    required this.isDriver,
    this.isFirst = false,
    this.isLast = false,
    super.key,
  });

  final NotificationModel notificationModel;
  final bool isDriver;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log(notificationModel.body.toString());
        log(notificationModel.referenceId.toString());

        if (notificationModel.referenceTable == 'shipments') {
          if (isDriver) {
            if (notificationModel.isCurrent == 1) {
              context.read<MainCubit>().changeIndex(0);
            } else {
              if (notificationModel.hasShipment == 0) {
                // Navigator.pushNamed(
                //   context,
                //   Routes.driverShipmentDetailsRoute,
                //   arguments: DriverSHipmentsArgs(
                //     shipmentId: notificationModel.referenceId.toString(),
                //   ),
                // );
              } else {
                _showNotificationDialog(context);
              }
            }
          } else {
            // Navigator.pushNamed(
            //   context,
            //   Routes.userShipmentDetailsRoute,
            //   arguments: UserShipmentDetailsArgs(
            //     shipmentId: notificationModel.referenceId.toString(),
            //   ),
            // );
          }
        } else {
          _showNotificationDialog(context);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? Radius.circular(12.r) : Radius.zero,
            topRight: isFirst ? Radius.circular(12.r) : Radius.zero,
            bottomLeft: isLast ? Radius.circular(12.r) : Radius.zero,
            bottomRight: isLast ? Radius.circular(12.r) : Radius.zero,
          ),
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              height: 50.h,
              width: 50.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Image.asset(
                  ImageAssets.logo,
                  height: 35.h,
                  width: 35.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notificationModel.title ?? '',
                          style: getBoldStyle(
                            fontSize: 15.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        _formatTime(notificationModel.createdAt),
                        style: getRegularStyle(
                          color: AppColors.darkGrey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  Text(
                    notificationModel.body ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      color:
                          notificationModel.body != null &&
                              (notificationModel.body!.contains('قبول') ||
                                  notificationModel.body!.contains('accepted'))
                          ? AppColors.green
                          : AppColors.darkGrey,
                      fontSize: 13.sp,
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

  String _formatTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      DateTime date;
      if (dateTime.contains('T')) {
        date = DateTime.parse(dateTime);
      } else {
        // Handle alternative formats
        date = DateTime.parse(dateTime);
      }
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return dateTime;
    }
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "notification_details".tr(),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Text(
            notificationModel.body ?? "",
            style: TextStyle(fontSize: 14.sp),
          ),
        );
      },
    );
  }
}
