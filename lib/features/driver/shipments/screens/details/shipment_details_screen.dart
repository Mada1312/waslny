import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/shipments/screens/widgets/custom_user_info.dart';
import 'package:waslny/features/user/shipments/screens/details/widgets/rate_bottomsheet.dart';

import '../../../../user/shipments/screens/details/widgets/follow_shipment.dart';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';
import '../widgets/shipment_details_body.dart';

class DriverSHipmentsArgs {
  final String? shipmentId;
  final bool isNotification;
  DriverSHipmentsArgs({this.isNotification = false, this.shipmentId});
}

class DriverShipmentDetailsScreen extends StatefulWidget {
  const DriverShipmentDetailsScreen({
    super.key,
    required this.args,
  });
  final DriverSHipmentsArgs args;
  @override
  State<DriverShipmentDetailsScreen> createState() =>
      _DriverShipmentDetailsScreenState();
}

class _DriverShipmentDetailsScreenState
    extends State<DriverShipmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverShipmentsCubit>().changeSelectedDriver(null);
    context
        .read<DriverShipmentsCubit>()
        .getShipmentDetails(id: widget.args.shipmentId ?? '');
  }

  // int status = 0;
  // 0: new, 1: pending, 2: loaded, 3: delivered
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverShipmentsCubit, DriverShipmentsState>(
        builder: (context, state) {
      var cubit = context.read<DriverShipmentsCubit>();

      return WillPopScope(
        onWillPop: () async {
          if (widget.args.isNotification) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.mainRoute, arguments: true, (route) => false);
          } else {
            Navigator.pop(context);
          }
          return true;
        },
        child: Scaffold(
          appBar: customAppBar(
            context,
            title: 'shipment_details'.tr(),
            onBack: () {
              if (widget.args.isNotification) {
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.mainRoute,
                    arguments: true,
                    (route) => false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getHorizontalPadding(context),
            ),
            child: Column(
              children: [
                Expanded(
                  child: state is GetShipmentDetailsErrorState
                      ? CustomNoDataWidget(
                          message: 'error_happened'.tr(),
                          onTap: () {
                            cubit.getShipmentDetails(
                                id: widget.args.shipmentId ?? '');
                          },
                        )
                      : state is GetShipmentDetailsLoadingState ||
                              cubit.shipmentDetails?.data == null
                          ? const Center(child: CustomLoadingIndicator())
                          : SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.h, horizontal: 10.w),
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
                                            withContactWidget: cubit
                                                        .shipmentDetails
                                                        ?.data
                                                        ?.status ==
                                                    2 ||
                                                cubit.shipmentDetails?.data
                                                        ?.status ==
                                                    3,
                                            shipmentId:
                                                widget.args.shipmentId ?? '',
                                            driverId: cubit.shipmentDetails
                                                ?.data?.driver?.id
                                                .toString(),
                                            roomToken: cubit.shipmentDetails
                                                ?.data?.roomToken,
                                            shipmentCode: cubit
                                                .shipmentDetails?.data?.code,
                                            exporter: cubit
                                                .shipmentDetails?.data?.user,
                                            inProgress: cubit.shipmentDetails
                                                    ?.data?.driverStatus ==
                                                0,
                                            hint: cubit.shipmentDetails?.data
                                                    ?.shipmentDateTimeDiff ??
                                                "",
                                            // ? "${"remaining_for_loading".tr()} 2 hours"
                                            // : "${"loaded_at".tr()} ${cubit.shipmentDetails?.data?.inProgressAt ?? ""}",
                                          )),
                                    ),
                                    20.h.verticalSpace,
                                    ShipmentDetailsDriverBody(
                                      shipmentDetails:
                                          cubit.shipmentDetails?.data,
                                    ),
                                    if (cubit.shipmentDetails?.data?.status ==
                                            2 ||
                                        cubit.shipmentDetails?.data?.status ==
                                            3) ...[
                                      20.h.verticalSpace,
                                      Divider(
                                        color: AppColors.grey.withOpacity(0.3),
                                        height: 1,
                                      ),
                                      30.h.verticalSpace,
                                      FollowShipmentWidget(
                                          shipmentTracking: cubit
                                              .shipmentDetails
                                              ?.data
                                              ?.shipmentTracking),
                                    ],
                                    50.h.verticalSpace,
                                  ]),
                            ),
                ),
                if (cubit.shipmentDetails?.data?.status == 3 &&
                    cubit.shipmentDetails?.data?.isRate == false) ...[
                  Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getHorizontalPadding(context),
                      ),
                      child: CustomButton(
                          title: "rating".tr(),
                          onPressed: () {
                            showAddRateBottomSheet(context,
                                shipmentId: widget.args.shipmentId ?? "",
                                participantId: cubit
                                        .shipmentDetails?.data?.user?.id
                                        .toString() ??
                                    "",
                                isDriver: true);
                          })),
                  20.h.verticalSpace,
                ]
              ],
            ),
          ),
        ),
      );
    });
  }
}
