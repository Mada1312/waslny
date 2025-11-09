import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/call_method.dart';

import '../../../../general/chat/screens/message_screen.dart';

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
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: MySvgWidget(
              path: AppIcons.messageIcon,
              imageColor: AppColors.secondPrimary,
            ),
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
