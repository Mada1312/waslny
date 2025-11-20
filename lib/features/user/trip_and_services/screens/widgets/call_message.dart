import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/call_method.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';

import '../../../../general/chat/screens/message_screen.dart';
import 'package:badges/badges.dart' as badges;

class CustomCallAndMessageWidget extends StatelessWidget {
  const CustomCallAndMessageWidget({
    super.key,
    this.phoneNumber,
    this.tripId,
    this.shipmentCode,
    this.driverId,
    this.roomToken,
    this.name,
    this.receiverId,
    this.isDriver = false,
  });
  final String? phoneNumber;
  final String? roomToken;
  final String? shipmentCode;
  final String? tripId;
  final String? driverId;
  final String? name;
  final String? receiverId;
  final bool isDriver;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            //!todo

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessageScreen(
                  model: MainUserAndRoomChatModel(
                    driverId: driverId,
                    tripId: tripId,
                    receiverId: receiverId,
                    chatId: roomToken,
                    title: "#${shipmentCode ?? ''}-$name",
                    isDriver: isDriver,
                  ),
                ),
              ),
            );
          },
          child: StreamBuilder<int>(
            stream: context.watch<ChatCubit>().getUnreadMessagesCountStream(
              roomToken ?? '',
            ),
            builder: (context, snapshot) {
              // Check if data is available and ready (or just show the icon)
              if (snapshot.connectionState == ConnectionState.waiting) {
                // You can return a simple icon or a subtle loading indicator
                return yourOriginalIconWidget();
              }

              // Get the unread count (default to 0 if null)
              final unreadCount = snapshot.data ?? 0;

              return badges.Badge(
                // 💡 CORRECTION HERE: Display the actual integer data
                badgeContent: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ), // Add style for visibility
                ),

                // Show badge only if roomToken exists AND count is greater than 0
                showBadge: roomToken != null && unreadCount > 0,

                badgeStyle: badges.BadgeStyle(
                  badgeColor:
                      AppColors.error, // Use a contrasting color like error/red
                  padding: EdgeInsets.all(5),
                ),

                child: yourOriginalIconWidget(),
              );
            },
          ),
        ),
        10.w.horizontalSpace,
        GestureDetector(
          onTap: () {
            if (phoneNumber == null || phoneNumber!.isEmpty) {
              return;
            }
            phoneCallMethod(phoneNumber!);
          },
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: MySvgWidget(
              path: AppIcons.call,
              imageColor: AppColors.secondPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

Widget yourOriginalIconWidget() {
  return CircleAvatar(
    backgroundColor: AppColors.primary,
    child: MySvgWidget(
      path: AppIcons.messageIcon,
      imageColor: AppColors.secondPrimary,
    ),
  );
}
