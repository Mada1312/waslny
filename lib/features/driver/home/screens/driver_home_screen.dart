import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/user_info.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/driver/shipments/cubit/cubit.dart';

import 'package:waslny/features/driver/shipments/screens/widgets/custom_user_info.dart';
import 'package:waslny/features/driver/shipments/screens/widgets/shipment_details_body.dart';
import 'package:waslny/features/driver/shipments/screens/widgets/shipment_widget.dart';
import 'package:waslny/features/user/shipments/screens/details/widgets/follow_shipment.dart';
import 'package:waslny/features/user/shipments/screens/details/widgets/shipment_details_body.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({
    super.key,
  });
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    if (context.read<DriverHomeCubit>().homeModel == null)
      context.read<DriverHomeCubit>().getDriverHomeData(context);

    FirebaseMessaging.onMessage.listen((message) async {
      if (message.data['reference_table'] == "shipments" &&
          message.data['user_type'].toString() == "1") {
        context.read<DriverHomeCubit>().getDriverHomeData(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
        builder: (context, state) {
      var cubit = context.read<DriverHomeCubit>();
      return Scaffold(
        body: Column(
          children: [
            SizedBox(
                height: getHeightSize(context) / 3.5,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: getHeightSize(context) / 3.5,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImageAssets.driverCover),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.6),
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: getHorizontalPadding(context),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomUserInfo(
                                  textColor: AppColors.white,
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          MySvgWidget(
                                              path: AppIcons.drivers,
                                              // height: 25.h,
                                              width: 25.sp,
                                              imageColor: AppColors.primary),
                                          10.w.horizontalSpace,
                                          Flexible(
                                            child: Text(
                                              "${"drivers_count".tr()}${cubit.homeModel?.data?.totalDrivers.toString() ?? "0"}",
                                              style: getSemiBoldStyle(
                                                fontSize: 18.sp,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Row(
                                        children: [
                                          MySvgWidget(
                                            path: AppIcons.shipmentCount,
                                            // height: 25.h,
                                            width: 25.sp,
                                          ),
                                          10.w.horizontalSpace,
                                          Flexible(
                                            child: Text(
                                              "${"shipments_count".tr()}${cubit.homeModel?.data?.totalShipments.toString() ?? "0"}",
                                              style: getSemiBoldStyle(
                                                fontSize: 18.sp,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: getHorizontalPadding(context),
                            vertical: 20.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                          ),
                          child: cubit.homeModel?.data == null
                              ? SizedBox()
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cubit.homeModel?.data?.hasShipment ==
                                                false
                                            ? "new_shipments".tr()
                                            : "shipment_details".tr(),
                                        style: getSemiBoldStyle(
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                    if (cubit.homeModel?.data
                                            ?.currentDriverShipment?.status ==
                                        1)
                                      InkWell(
                                        onTap: () {
                                          warningDialog(context,
                                              title: "delete_shipment_sure"
                                                  .tr(), onPressedOk: () {
                                            cubit.cancleCurrentShipment(
                                              shipmentId: cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.currentDriverShipment
                                                      ?.id
                                                      .toString() ??
                                                  "",
                                              context: context,
                                            );
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.red,
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                          ),
                                          child: Text(
                                            "cancel".tr(),
                                            style: getRegularStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                        )
                      ],
                    ),
                  ],
                )),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getHorizontalPadding(context), vertical: 10.h),
                child: state is DriverHomeError
                    ? CustomNoDataWidget(
                        message: 'error_happened'.tr(),
                        onTap: () {
                          cubit.getDriverHomeData(context);
                        },
                      )
                    : state is DriverHomeLoading ||
                            cubit.homeModel?.data == null
                        ? const Center(child: CustomLoadingIndicator())
                        : cubit.homeModel?.data?.hasShipment == false
                            ? cubit.homeModel?.data?.shipments?.isEmpty == true
                                ? CustomNoDataWidget(
                                    message: 'no_shipments'.tr(),
                                    onTap: () {
                                      cubit.getDriverHomeData(context);
                                    },
                                  )
                                : RefreshIndicator(
                                    onRefresh: () =>
                                        cubit.getDriverHomeData(context),
                                    child: _buildNewShipmentsBody(
                                        cubit.homeModel?.data?.shipments),
                                  )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    cubit.getDriverHomeData(context),
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.h,
                                                horizontal: 10.w),
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
                                            child: CustomTheUserInfo(
                                              withContactWidget: true,
                                              driverId: cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.currentDriverShipment
                                                      ?.driver
                                                      ?.driverId
                                                      ?.toString() ??
                                                  cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.currentDriverShipment
                                                      ?.driver
                                                      ?.id
                                                      ?.toString(),
                                              shipmentCode: cubit
                                                  .homeModel
                                                  ?.data
                                                  ?.currentDriverShipment
                                                  ?.code,
                                              shipmentId: cubit.homeModel?.data
                                                  ?.currentDriverShipment?.id
                                                  .toString(),
                                              exporter: cubit.homeModel?.data
                                                  ?.currentDriverShipment?.user,
                                              inProgress: cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.currentDriverShipment
                                                      ?.driverStatus ==
                                                  0,
                                              hint: cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.currentDriverShipment
                                                      ?.shipmentDateTimeDiff ??
                                                  "",
                                              // ? "${"remaining_for_loading".tr()} 2 hours"
                                              // : "${"loaded_at".tr()} ${cubit.homeModel?.data?.currentDriverShipment?.inProgressAt ?? ""}",
                                            )),
                                      ),
                                      20.h.verticalSpace,
                                      ShipmentDetailsDriverBody(
                                        shipmentDetails: cubit.homeModel?.data
                                            ?.currentDriverShipment,
                                      ),
                                      if (cubit
                                                  .homeModel
                                                  ?.data
                                                  ?.currentDriverShipment
                                                  ?.status ==
                                              2 ||
                                          cubit
                                                  .homeModel
                                                  ?.data
                                                  ?.currentDriverShipment
                                                  ?.status ==
                                              3) ...[
                                        20.h.verticalSpace,
                                        Divider(
                                          color:
                                              AppColors.grey.withOpacity(0.3),
                                          height: 1,
                                        ),
                                        30.h.verticalSpace,
                                        FollowShipmentWidget(
                                          shipmentTracking: cubit
                                              .homeModel
                                              ?.data
                                              ?.currentDriverShipment
                                              ?.shipmentTracking,
                                        ),
                                        20.h.verticalSpace,
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                getHorizontalPadding(context),
                                            vertical: 10.h,
                                          ),
                                          child: cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.currentDriverShipment
                                                      ?.driverIsDeliverd ==
                                                  1
                                              ? Text(
                                                  "waiting_for_exporter_confirmation"
                                                      .tr(),
                                                  textAlign: TextAlign.center,
                                                  style: getSemiBoldStyle(
                                                    // fontSize: 16.sp,
                                                    color: AppColors.primary,
                                                  ),
                                                )
                                              : CustomButton(
                                                  title:
                                                      // cubit.isServiceRunning
                                                      //     ? "delivered".tr()
                                                      //     : cubit
                                                      //                 .homeModel
                                                      //                 ?.data
                                                      //                 ?.currentDriverShipment
                                                      //                 ?.shipmentTracking
                                                      //                 ?.isEmpty ??
                                                      //             true
                                                      //         ? "start_trip".tr()
                                                      //         :
                                                      "enable_tracking".tr(),
                                                  onPressed: () {
                                                    // if (cubit
                                                    //     .isServiceRunning) {
                                                    // cubit.stopLocationService();
                                                    warningDialog(context,
                                                        title:
                                                            "deliver_shipment_sure_desc"
                                                                .tr(),
                                                        onPressedOk: () {
                                                      cubit.completeShipment(
                                                          shipmentId: cubit
                                                                  .homeModel
                                                                  ?.data
                                                                  ?.currentDriverShipment
                                                                  ?.id
                                                                  .toString() ??
                                                              "",
                                                          context: context);
                                                    });
                                                    // } else {
                                                    //   cubit
                                                    //       .startLocationService(
                                                    //           context: context);
                                                    // }
                                                  }),
                                        )
                                      ],
                                    ],
                                  ),
                                ),
                              ),
              ),
            ),
          ],
        ),
      );
    });
  }

  ListView _buildNewShipmentsBody(List<ShipmentDriverModel>? shipments) {
    return ListView.separated(
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 3.h,
        ),
        child: DriverShipmentItemWidget(
            withContactWidget: false, shipment: shipments?[index]),
      ),
      separatorBuilder: (context, index) => 20.h.verticalSpace,
      itemCount: shipments?.length ?? 0,
    );
  }
}
