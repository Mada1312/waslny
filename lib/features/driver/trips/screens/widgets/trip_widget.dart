import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/driver/trips/cubit/cubit.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/custom_from_to.dart';
import 'package:badges/badges.dart' as badges;
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.second2Primary,
        borderRadius: BorderRadius.circular(10.r),
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
            to: trip?.serviceToName ?? trip?.to,
            fromLat: trip?.fromLat,
            fromLng: trip?.fromLong,
            toLat: trip?.toLat,
            toLng: trip?.toLong,
            isDriverAccepted: trip?.isDriverAccept == 1,
            isDriverArrived: trip?.isDriverArrived == 1,
          ),
          // 10.h.verticalSpace,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: context
                        .watch<ChatCubit>()
                        .getUnreadMessagesCountStream(trip?.roomToken ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return yourOriginalIconWidget(context);
                      }

                      final unreadCount = snapshot.data ?? 0;

                      return badges.Badge(
                        badgeContent: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ), // Add style for visibility
                        ),

                        showBadge: trip?.roomToken != null && unreadCount > 0,

                        badgeStyle: badges.BadgeStyle(
                          badgeColor: AppColors
                              .error, // Use a contrasting color like error/red
                          padding: EdgeInsets.all(5),
                        ),

                        child: SizedBox(
                          width: double.infinity,

                          child: yourOriginalIconWidget(context),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      warningDialog(
                        context,
                        title: "are_you_sure_you_want_to_cancel_trip".tr(),
                        onPressedOk: () {
                          context.read<DriverTripsCubit>().cancleTrip(
                            tripId: trip?.id ?? 0,
                            context: context,
                          );
                        },
                      );
                    },
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
    );
  }

  ElevatedButton yourOriginalIconWidget(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageScreen(
              model: MainUserAndRoomChatModel(
                driverId: trip?.driverId.toString(),
                receiverId: trip?.userId.toString(),
                chatId: trip?.roomToken,
                tripId: trip?.id.toString(),
                title: "#${trip?.code ?? ''}",

                isDriver: true,
              ),
            ),
          ),
        );
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        "chat".tr(),
        style: getRegularStyle(color: AppColors.primary),
      ),
    );
  }
}
