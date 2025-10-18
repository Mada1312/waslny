import 'package:waslny/core/exports.dart';
import 'package:waslny/features/user/add_new_trip/screens/add_new_trip.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/custom_driver_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:screenshot/screenshot.dart';

import '../../cubit/cubit.dart';
import '../../cubit/state.dart';
import 'widgets/follow_shipment.dart';
import 'widgets/rate_bottomsheet.dart';
import 'widgets/shipment_details_body.dart';

class UserShipmentDetailsArgs {
  final String shipmentId;
  final bool isFromNotification;

  UserShipmentDetailsArgs({
    required this.shipmentId,
    this.isFromNotification = false,
  });
}

class UserShipmentDetailsScreen extends StatefulWidget {
  const UserShipmentDetailsScreen({super.key, required this.args});
  final UserShipmentDetailsArgs args;
  @override
  State<UserShipmentDetailsScreen> createState() =>
      _UserShipmentDetailsScreenState();
}

class _UserShipmentDetailsScreenState extends State<UserShipmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserTripAndServicesCubit>().changeSelectedDriver(null);
    context.read<UserTripAndServicesCubit>().getShipmentDetails(
      id: widget.args.shipmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserTripAndServicesCubit, UserTripAndServicesState>(
      builder: (context, state) {
        var cubit = context.read<UserTripAndServicesCubit>();

        return WillPopScope(
          onWillPop: () async {
            if (widget.args.isFromNotification) {
              print("pop");
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.mainRoute,
                arguments: false,
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
            return true;
          },
          child: Scaffold(
            appBar: buildAppBar(context, cubit),
            body: state is ShipmentDetailsErrorState
                ? CustomNoDataWidget(
                    message: 'error_happened'.tr(),
                    onTap: () {
                      cubit.getShipmentDetails(id: widget.args.shipmentId);
                      cubit.changeSelectedDriver(null);
                    },
                  )
                : state is ShipmentDetailsLoadingState ||
                      cubit.shipmentDetailsModel?.data == null
                ? const Center(child: CustomLoadingIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            await cubit.getShipmentDetails(
                              id: widget.args.shipmentId,
                            );
                            cubit.changeSelectedDriver(null);
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Screenshot(
                              controller: cubit.screenshotController,
                              child: Container(
                                color: AppColors.white,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: getHorizontalPadding(context),
                                    vertical: 20.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (cubit
                                              .shipmentDetailsModel
                                              ?.data
                                              ?.status !=
                                          "0")
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10.h,
                                              horizontal: 10.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.grey
                                                      .withOpacity(0.3),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 3),
                                                ),
                                                BoxShadow(
                                                  color: AppColors.grey
                                                      .withOpacity(0.3),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, -3),
                                                ),
                                              ],
                                            ),
                                            child: CustomDriverInfo(
                                              isFavWidget: true,
                                              roomToken: null,
                                              shipmentCode: cubit
                                                  .shipmentDetailsModel
                                                  ?.data
                                                  ?.code,
                                              tripId:
                                                  cubit
                                                      .shipmentDetailsModel
                                                      ?.data
                                                      ?.id
                                                      ?.toString() ??
                                                  '',

                                              driver: cubit
                                                  .shipmentDetailsModel
                                                  ?.data
                                                  ?.driver,
                                              hint:
                                                  cubit
                                                      .shipmentDetailsModel
                                                      ?.data
                                                      ?.shipmentDateTimeDiff ??
                                                  "",
                                              // ? "remaining_for_loading"
                                              //         .tr() +
                                              //     " 2 hours"
                                              // : "loaded_at".tr() +
                                              //     " ${cubit.shipmentDetailsModel?.data?.inProgressAt ?? ""}",
                                            ),
                                          ),
                                        ),
                                      if (cubit
                                              .shipmentDetailsModel
                                              ?.data
                                              ?.status !=
                                          "0")
                                        20.h.verticalSpace,
                                      ShipmentDetailsUserBody(
                                        shipmentData:
                                            cubit.shipmentDetailsModel?.data,
                                      ),
                                      if (cubit
                                              .shipmentDetailsModel
                                              ?.data
                                              ?.status !=
                                          "1") ...[
                                        20.h.verticalSpace,
                                        Divider(
                                          color: AppColors.grey.withOpacity(
                                            0.3,
                                          ),
                                          height: 1,
                                        ),
                                        30.h.verticalSpace,
                                      ],
                                      if (cubit
                                              .shipmentDetailsModel
                                              ?.data
                                              ?.status ==
                                          "0")
                                        buildCurrentDrivers(
                                          cubit,
                                          drivers: cubit
                                              .shipmentDetailsModel
                                              ?.data
                                              ?.shipmentDriversRequests,
                                        )
                                      else if (cubit
                                                  .shipmentDetailsModel
                                                  ?.data
                                                  ?.status ==
                                              "2" ||
                                          cubit
                                                  .shipmentDetailsModel
                                                  ?.data
                                                  ?.status ==
                                              "3")
                                        FollowShipmentWidget(
                                          shipmentTracking: cubit
                                              .shipmentDetailsModel
                                              ?.data
                                              ?.shipmentLocations,
                                        ),

                                      // 50.h.verticalSpace,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getHorizontalPadding(context) * 2,
                        ),
                        child: cubit.shipmentDetailsModel?.data?.status == "0"
                            ? CustomButton(
                                title: "assign_driver".tr(),
                                isDisabled: cubit.selectedDriver == null,
                                onPressed: () {
                                  warningDialog(
                                    context,
                                    title: "select_this_driver_sure".tr(),
                                    onPressedOk: () {
                                      cubit.assignDriver(
                                        shipmentId: widget.args.shipmentId,
                                        context: context,
                                      );
                                    },
                                  );
                                },
                              )
                            : cubit.shipmentDetailsModel?.data?.status == "1"
                            ? CustomButton(
                                title: "loaded".tr(),
                                onPressed: () {
                                  warningDialog(
                                    context,
                                    title: "load_shipment_sure".tr(),
                                    onPressedOk: () {
                                      cubit.updateShipmentStatus(
                                        shipmentId: widget.args.shipmentId,
                                        status: "2",
                                        context: context,
                                      );
                                    },
                                  );
                                },
                              )
                            : cubit.shipmentDetailsModel?.data?.status == "2" &&
                                  cubit
                                          .shipmentDetailsModel
                                          ?.data
                                          ?.driverIsDeliverd ==
                                      1
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: getHorizontalPadding(context),
                                  vertical: 10.h,
                                ),
                                child: CustomButton(
                                  title: "confirm_delivered".tr(),
                                  onPressed: () {
                                    warningDialog(
                                      context,
                                      title: "deliver_shipment_sure".tr(),
                                      onPressedOk: () {
                                        cubit.completeShipment(
                                          shipmentId: widget.args.shipmentId,
                                          context: context,
                                        );
                                      },
                                    );
                                  },
                                ),
                              )
                            : cubit.shipmentDetailsModel?.data?.status == "3" &&
                                  cubit.shipmentDetailsModel?.data?.isRated ==
                                      false
                            ? CustomButton(
                                title: "rating".tr(),
                                onPressed: () {
                                  showAddRateBottomSheet(
                                    context,
                                    shipmentId: widget.args.shipmentId,
                                    participantId:
                                        cubit
                                            .shipmentDetailsModel
                                            ?.data
                                            ?.driver
                                            ?.id
                                            .toString() ??
                                        "",
                                    isDriver: false,
                                  );
                                },
                              )
                            : SizedBox(),
                      ),
                      20.h.verticalSpace,
                    ],
                  ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget buildAppBar(
    BuildContext context,
    UserTripAndServicesCubit cubit,
  ) {
    return customAppBar(
      context,
      title: 'trip_details'.tr(),
      height: 100.h,
      onBack: widget.args.isFromNotification
          ? () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.mainRoute,
                arguments: false,
                (route) => false,
              );
            }
          : () {
              Navigator.pop(context);
            },
      actions: cubit.shipmentDetailsModel?.data?.status == null
          ? []
          : cubit.shipmentDetailsModel?.data?.status == "0"
          ? [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.addNewTripRoute,
                    arguments: AddTripArgs(
                      shipment: cubit.shipmentDetailsModel?.data,
                    ),
                  );
                },
                child: MySvgWidget(
                  path: AppIcons.edit,
                  imageColor: AppColors.primary,
                  height: 26.h,
                  width: 26.h,
                ),
              ),
              20.w.horizontalSpace,
              InkWell(
                onTap: () {
                  warningDialog(
                    context,
                    title: "delete_shipment_sure".tr(),
                    onPressedOk: () {
                      cubit.deleteShipment(
                        shipmentId: widget.args.shipmentId,
                        context: context,
                      );
                    },
                  );
                },
                child: MySvgWidget(
                  path: AppIcons.delete,
                  imageColor: AppColors.red,
                  height: 24.h,
                  width: 24.h,
                ),
              ),
              20.w.horizontalSpace,
            ]
          : [
              if (cubit.shipmentDetailsModel?.data?.status == "3")
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: GestureDetector(
                    child: Icon(
                      Icons.share,
                      color: AppColors.primary,
                      size: 24.w,
                    ),
                    onTap: () async {
                      await cubit.captureScreenshot();
                    },
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getHorizontalPadding(context),
                ),
                child: Column(
                  children: [
                    Text(
                      "enable_notification".tr(),
                      style: getRegularStyle(fontSize: 14.sp),
                    ),
                    CupertinoSwitch(
                      activeTrackColor: AppColors.primary,
                      value: cubit.enableNotifications ?? false,
                      onChanged: (value) {
                        cubit.changeEnableNotifications(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
    );
  }

  Column buildCurrentDrivers(
    UserTripAndServicesCubit cubit, {
    List<Driver>? drivers,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("suggested_drivers".tr(), style: getMediumStyle(fontSize: 16.sp)),
        20.h.verticalSpace,
        if (drivers == null || drivers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: CustomNoDataWidget(message: 'no_drivers_found'.tr()),
            ),
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  cubit.changeSelectedDriver(drivers[index]);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 10.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
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
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: cubit.selectedDriver == drivers[index],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        activeColor: AppColors.primary,
                        checkColor: AppColors.white,
                        onChanged: (c) {
                          cubit.changeSelectedDriver(drivers[index]);
                        },
                      ),
                      Expanded(
                        child: CustomDriverInfo(
                          driver: drivers[index],
                          roomToken: null,
                          shipmentCode: cubit.shipmentDetailsModel?.data?.code,
                          tripId:
                              cubit.shipmentDetailsModel?.data?.id
                                  ?.toString() ??
                              '',
                          hint:
                              cubit
                                  .shipmentDetailsModel
                                  ?.data
                                  ?.shipmentDateTimeDiff ??
                              "",
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return 20.h.verticalSpace;
            },
            itemCount: drivers?.length ?? 0,
          ),
      ],
    );
  }
}
