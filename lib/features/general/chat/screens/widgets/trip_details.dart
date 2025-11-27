import 'package:waslny/core/exports.dart';
import 'package:waslny/core/notification_services/notification_service.dart';
import 'package:waslny/core/utils/call_method.dart';
import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/general/chat/cubit/chat_state.dart';
import 'package:waslny/features/user/driver_details/screens/driver_details.dart';

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
                    if (state is GetTripStatusLoadingState)
                      SizedBox.shrink()
                    else ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isDriver == false) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriverProfileScreen(
                                    driverId:
                                        cubit
                                            .getTripDetailsModel
                                            ?.data
                                            ?.driver
                                            ?.id
                                            .toString() ??
                                        "",

                                    tripId:
                                        cubit.getTripDetailsModel?.data?.id
                                            .toString() ??
                                        "",
                                    shipmentCode:
                                        cubit.getTripDetailsModel?.data?.code
                                            .toString() ??
                                        "",
                                  ),
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
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
                                      offset: Offset(
                                        0,
                                        3,
                                      ), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: CustomNetworkImage(
                                  image: isDriver
                                      ? cubit
                                                .getTripDetailsModel
                                                ?.data
                                                ?.user
                                                ?.image ??
                                            ""
                                      : cubit
                                                .getTripDetailsModel
                                                ?.data
                                                ?.driver
                                                ?.image ??
                                            "",
                                  isUser: true,
                                  height: 50.sp,
                                  width: 50.sp,
                                  borderRadius: 1000,
                                ),
                              ),
                              12.horizontalSpace,
                              Expanded(
                                child: Text(
                                  isDriver == true
                                      ? cubit
                                                .getTripDetailsModel
                                                ?.data
                                                ?.user
                                                ?.name ??
                                            ""
                                      : cubit
                                                .getTripDetailsModel
                                                ?.data
                                                ?.driver
                                                ?.name ??
                                            "",
                                  style: getBoldStyle(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          String? phoneNumber = isDriver
                              ? cubit.getTripDetailsModel?.data?.user?.phone
                              : cubit.getTripDetailsModel?.data?.driver?.phone;
                          if (phoneNumber == null || phoneNumber.isEmpty) {
                            return;
                          }
                          phoneCallMethod(phoneNumber);
                        },
                        child: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: MySvgWidget(
                            path: AppIcons.call,
                            imageColor: AppColors.secondPrimary,
                          ),
                        ),
                      ),
                      10.horizontalSpace,
                    ],
                  ],
                ),
              ),
            ),
            Divider(thickness: 2.h, color: AppColors.white),
            10.verticalSpace,
            (state is GetTripStatusLoadingState)
                ? Center(
                    child: Center(
                      child: LinearProgressIndicator(
                        color: AppColors.secondPrimary,
                        backgroundColor: AppColors.grey.withOpacity(0.3),
                      ),
                    ),
                  )
                : isDriver
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        if (cubit.getTripDetailsModel?.data?.isDriverAccept ==
                                0 &&
                            cubit
                                    .getTripDetailsModel
                                    ?.data
                                    ?.isDriverAnotherTrip ==
                                0) ...[
                          Flexible(
                            // flex: 1,
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
                        ],
                        if (cubit.getTripDetailsModel?.data?.status == 0 &&
                            cubit.getTripDetailsModel?.data?.isDriverArrived ==
                                0 &&
                            cubit.getTripDetailsModel?.data?.isDriverAccept ==
                                1 &&
                            cubit
                                    .getTripDetailsModel
                                    ?.data
                                    ?.isDriverAnotherTrip ==
                                0) ...[
                          Flexible(
                            // flex: 1,
                            child: CustomButton(
                              title: "arrived".tr(),
                              btnColor: AppColors.secondPrimary,
                              textColor: AppColors.primary,
                              isDisabled:
                                  cubit
                                      .getTripDetailsModel
                                      ?.data
                                      ?.isUserAccept ==
                                  0,
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
                                      receiverId: cubit
                                          .getTripDetailsModel
                                          ?.data
                                          ?.user
                                          ?.id
                                          .toString(),
                                      chatId: cubit
                                          .getTripDetailsModel
                                          ?.data
                                          ?.roomToken,

                                      context: context,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          10.w.horizontalSpace,
                        ],
                        if (cubit.getTripDetailsModel?.data?.status == 0 &&
                            cubit.getTripDetailsModel?.data?.isDriverAccept ==
                                1 &&
                            cubit.getTripDetailsModel?.data?.isDriverArrived ==
                                1) ...[
                          Flexible(
                            child: CustomButton(
                              title:
                                  cubit.getTripDetailsModel?.data?.isService ==
                                      1
                                  ? "start_service".tr()
                                  : "start_trip".tr(),
                              isDisabled:
                                  cubit
                                      .getTripDetailsModel
                                      ?.data
                                      ?.isUserAccept ==
                                  0,
                              onPressed: () {
                                warningDialog(
                                  context,
                                  title: "are_you_sure_you_want_to_start_trip"
                                      .tr(),
                                  onPressedOk: () {
                                    cubit.startTrip(
                                      tripId:
                                          cubit.getTripDetailsModel?.data?.id ??
                                          0,
                                      context: context,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          10.w.horizontalSpace,
                        ],
                        if (cubit.getTripDetailsModel?.data?.status == 1 &&
                            cubit.getTripDetailsModel?.data?.isDriverAccept ==
                                1 &&
                            cubit.getTripDetailsModel?.data?.isDriverArrived ==
                                1) ...[
                          Flexible(
                            child: CustomButton(
                              title:
                                  cubit.getTripDetailsModel?.data?.isService ==
                                      1
                                  ? "end_service".tr()
                                  : "end_trip".tr(),
                              btnColor: AppColors.red,
                              textColor: AppColors.white,
                              isDisabled:
                                  cubit.getTripDetailsModel?.data?.isService ==
                                      0 &&
                                  cubit
                                          .getTripDetailsModel
                                          ?.data
                                          ?.isUserStartTrip ==
                                      0,
                              onPressed: () {
                                warningDialog(
                                  context,
                                  title: "are_you_sure_you_want_to_end_trip"
                                      .tr(),
                                  onPressedOk: () {
                                    cubit.endTrip(
                                      tripId:
                                          cubit.getTripDetailsModel?.data?.id ??
                                          0,
                                      context: context,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          10.w.horizontalSpace,
                        ],
                        if (cubit
                                .getTripDetailsModel
                                ?.data
                                ?.isDriverAnotherTrip ==
                            0)
                          Flexible(
                            child: CustomButton(
                              title: "reject".tr(),
                              btnColor: AppColors.secondPrimary,
                              textColor: AppColors.primary,
                              onPressed: () {
                                warningDialog(
                                  context,
                                  title: "are_you_sure_you_want_to_decline_trip"
                                      .tr(),
                                  onPressedOk: () {
                                    cubit.updateTripStatus(
                                      isDriver: isDriver,
                                      step: TripStep.isDriverAnotherTrip,
                                      context: context,
                                    );
                                  },
                                );
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
                        if (cubit.getTripDetailsModel?.data?.isUserAccept ==
                            0) ...[
                          Flexible(
                            flex: 3,
                            child: CustomButton(
                              title:
                                  cubit.getTripDetailsModel?.data?.isService ==
                                      1
                                  ? "accept_service".tr()
                                  : "accept_trip".tr(),
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
                        ],
                        if (cubit.getTripDetailsModel?.data?.isUserStartTrip ==
                                0 &&
                            cubit.getTripDetailsModel?.data?.isUserAccept ==
                                1 &&
                            cubit
                                    .getTripDetailsModel
                                    ?.data
                                    ?.isUserChangeCaptain ==
                                0 &&
                            cubit.getTripDetailsModel?.data?.isService ==
                                0) ...[
                          Flexible(
                            flex: 3,
                            child: CustomButton(
                              title: "start_trip".tr(),
                              isDisabled:
                                  cubit
                                          .getTripDetailsModel
                                          ?.data
                                          ?.isDriverAccept ==
                                      0 ||
                                  cubit
                                          .getTripDetailsModel
                                          ?.data
                                          ?.isDriverArrived ==
                                      0,
                              onPressed: () {
                                warningDialog(
                                  context,
                                  title: "are_you_sure_you_want_to_start_trip"
                                      .tr(),
                                  onPressedOk: () {
                                    cubit.updateTripStatus(
                                      isDriver: isDriver,
                                      step: TripStep.isUserStartTrip,
                                      context: context,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          10.w.horizontalSpace,
                        ],
                        if (cubit
                                .getTripDetailsModel
                                ?.data
                                ?.isUserChangeCaptain ==
                            0)
                          Flexible(
                            flex: 2,
                            child: CustomButton(
                              title: "change_captain".tr(),
                              btnColor: AppColors.secondPrimary,
                              textColor: AppColors.primary,
                              onPressed: () {
                                warningDialog(
                                  context,
                                  title:
                                      "are_you_sure_you_want_to_change_captain"
                                          .tr(),
                                  onPressedOk: () {
                                    cubit.updateTripStatus(
                                      isDriver: isDriver,
                                      step: TripStep.isUserChangeCaptain,
                                      context: context,
                                    );
                                  },
                                );
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
