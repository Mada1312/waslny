import 'package:waslny/core/exports.dart';
import 'package:waslny/core/notification_services/notification_service.dart';
import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/general/chat/cubit/chat_state.dart';

class CustomChatHeader extends StatelessWidget {
  const CustomChatHeader({
    super.key,
    required this.isDriver,
    required this.isNotification,
  });
  final bool isDriver;

  final bool isNotification;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        var cubit = context.read<ChatCubit>();
        return Column(
          children: [
            Container(
              color: AppColors.white,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.unSeen,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.sp),
                    topRight: Radius.circular(30.sp),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 25.sp,
                        color: AppColors.secondPrimary,
                      ),
                      onPressed: () {
                        MessageStateManager().isInChatRoom("1");
                        if (isNotification == true) {
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.mainRoute,
                            arguments: isDriver == true,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),

                    // SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.all(4.sp),
                      decoration: BoxDecoration(
                        color: AppColors.secondPrimary,
                        borderRadius: BorderRadius.circular(1000),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: CustomNetworkImage(
                        image:
                            "https://images.ctfassets.net/xjcz23wx147q/iegram9XLv7h3GemB5vUR/0345811de2da23fafc79bd00b8e5f1c6/Max_Rehkopf_200x200.jpeg",
                        isUser: true,
                        height: 50.sp,
                        width: 50.sp,
                        borderRadius: 1000,
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(child: Text("Max Rehkopf", style: getBoldStyle())),
                  ],
                ),
              ),
            ),
            Divider(thickness: 2.h, color: AppColors.white),
            10.verticalSpace,
            isDriver
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: CustomButton(
                            title: "accept".tr(),
                            onPressed: () {
                              warningDialog(
                                context,
                                title: "are_you_sure_you_want_to_accept_trip"
                                    .tr(),
                                onPressedOk: () {
                                  cubit.updateTripStatus(
                                    isDriver: isDriver,
                                    step: TripStep.isDriverAccept,
                                    context: context,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        10.w.horizontalSpace,
                        Flexible(
                          flex: 1,
                          child: CustomButton(
                            title: "arrived".tr(),
                            btnColor: AppColors.secondPrimary,
                            textColor: AppColors.primary,
                            onPressed: () {
                              warningDialog(
                                context,
                                title:
                                    "are_you_sure_you_want_to_confirm_arrival"
                                        .tr(),
                                onPressedOk: () {
                                  cubit.updateTripStatus(
                                    isDriver: isDriver,
                                    step: TripStep.isDriverArrived,
                                    context: context,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        10.w.horizontalSpace,
                        Flexible(
                          flex: 1,
                          child: CustomButton(
                            title: "another_trip".tr(),
                            btnColor: AppColors.secondPrimary,
                            textColor: AppColors.primary,
                            onPressed: () {
                              // warningDialog(
                              //   context,
                              //   title: "are_you_sure_you_want_to_decline_trip"
                              //       .tr(),
                              //   onPressedOk: () {
                              //     cubit.updateTripStatus(
                              //       isDriver: isDriver,
                              //       step: TripStep.isDriverDecline,
                              //       context: context,
                              //     );
                              //   },
                              // );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 3,
                          child: CustomButton(
                            title: "accept_trip".tr(),
                            onPressed: () {
                              warningDialog(
                                context,
                                title: "are_you_sure_you_want_to_accept_trip"
                                    .tr(),
                                onPressedOk: () {
                                  cubit.updateTripStatus(
                                    isDriver: isDriver,
                                    step: TripStep.isUserAccept,
                                    context: context,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        10.w.horizontalSpace,
                        Flexible(
                          flex: 2,
                          child: CustomButton(
                            title: "change_captain".tr(),
                            btnColor: AppColors.secondPrimary,
                            textColor: AppColors.primary,
                            onPressed: () {
                              // warningDialog(
                              //   context,
                              //   title:
                              //       "are_you_sure_you_want_to_change_captain"
                              //           .tr(),
                              //   onPressedOk: () {
                              //     // context.read<DriverHomeCubit>().cancleTrip(
                              //     //       tripId: trip?.id ?? 0,
                              //     //       context: context,
                              //     //     );
                              //   },
                              // );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        );
      },
    );
  }
}
