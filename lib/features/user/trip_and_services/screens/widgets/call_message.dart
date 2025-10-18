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
  });
  final String? phoneNumber;
  final String? roomToken;
  final String? shipmentCode;
  final String? tripId;
  final String? driverId;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    chatId: roomToken,
                    title: "#${shipmentCode ?? ''}-$name",
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
