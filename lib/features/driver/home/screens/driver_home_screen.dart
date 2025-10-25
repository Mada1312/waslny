import 'dart:developer' show log;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    // if (context.read<DriverHomeCubit>().homeModel == null)
    context.read<DriverHomeCubit>().getDriverHomeData(context);

    // FirebaseMessaging.onMessage.listen((message) async {
    //   if (message.data['reference_table'] == "shipments" &&
    //       message.data['user_type'].toString() == "1") {
    //     context.read<DriverHomeCubit>().getDriverHomeData(context);
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Image.asset(
                ImageAssets.splashBG,
                fit: BoxFit.cover,
                height: getHeightSize(context),
                width: getWidthSize(context),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: AppColors.secondPrimary.withOpacity(0.8),
                  height: getHeightSize(context),
                  width: getWidthSize(context),
                ),
              ),
              state is DriverHomeError
                  ? CustomNoDataWidget(
                      message: 'error_happened'.tr(),
                      onTap: () {
                        cubit.getDriverHomeData(context);
                      },
                    )
                  : state is DriverHomeLoading || cubit.homeModel?.data == null
                  ? const Center(child: CustomLoadingIndicator())
                  : const SizedBox(),
              if (cubit.isDataVerifided) DriverHomeUI(),
            ],
          ),
        );
      },
    );
  }
}

class DriverHomeUI extends StatelessWidget {
  const DriverHomeUI({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            await cubit.getDriverHomeData(context);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: getHeightSize(context),
              width: getWidthSize(context),
              child: state is DriverHomeError
                  ? CustomNoDataWidget(
                      message: 'error_happened'.tr(),
                      onTap: () {
                        cubit.getDriverHomeData(context);
                      },
                    )
                  : state is DriverHomeLoading || cubit.homeModel?.data == null
                  ? const Center(child: CustomLoadingIndicator())
                  : Column(
                      children: [
                        SafeArea(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 15.h,
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.grey.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, 3),
                                          ),
                                          BoxShadow(
                                            color: AppColors.grey.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, -3),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        // vertical: 8.h,
                                        horizontal: 15.w,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              cubit
                                                          .homeModel
                                                          ?.data
                                                          ?.user
                                                          ?.isActive ==
                                                      1
                                                  ? "online".tr()
                                                  : "offline".tr(),
                                              style: getBoldStyle(
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                          ),
                                          CupertinoSwitch(
                                            value:
                                                cubit
                                                    .homeModel
                                                    ?.data
                                                    ?.user
                                                    ?.isActive ==
                                                1,

                                            activeTrackColor:
                                                AppColors.secondPrimary,

                                            inactiveThumbColor: AppColors.white,
                                            thumbColor: AppColors.primary,
                                            onChanged: (value) {
                                              cubit.changeActiveStatus();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  12.w.horizontalSpace,
                                  GestureDetector(
                                    onTap: () {
                                      // Navigator.pushReplacementNamed(
                                      //   context,
                                      //   Routes.driverDataRoute,
                                      // );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.grey.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, 3),
                                          ),
                                          BoxShadow(
                                            color: AppColors.grey.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, -3),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 15.sp,
                                        horizontal: 15.sp,
                                      ),
                                      child: MySvgWidget(
                                        path: AppIcons.menu,
                                        height: 25.sp,
                                        width: 25.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        if (cubit.homeModel?.data?.user?.isActive == 1 &&
                            cubit.homeModel?.data?.currentTrip != null)
                          Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),

                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (cubit.homeModel?.data?.currentTrip == null)
                                  Expanded(child: Container())
                                else
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.grey.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, 3),
                                          ),
                                          BoxShadow(
                                            color: AppColors.grey.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, -3),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.currentTrip
                                                      ?.type ??
                                                  "",
                                              // "scheduled".tr(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: getBoldStyle(
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),

                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              MySvgWidget(
                                                path: AppIcons.date,
                                                height: 24.h,
                                              ),
                                              6.w.horizontalSpace,
                                              Text(
                                                cubit
                                                        .homeModel
                                                        ?.data
                                                        ?.currentTrip
                                                        ?.day ??
                                                    '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: getRegularStyle(),
                                              ),
                                            ],
                                          ),

                                          // 10.w.horizontalSpace,
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              MySvgWidget(
                                                path: AppIcons.dateTime,
                                                height: 24.h,
                                              ),
                                              6.w.horizontalSpace,
                                              Text(
                                                cubit
                                                        .homeModel
                                                        ?.data
                                                        ?.currentTrip
                                                        ?.time ??
                                                    '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: getRegularStyle(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                12.w.horizontalSpace,

                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.driverTripsRoute,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.grey.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 2,
                                          offset: const Offset(0, 3),
                                        ),
                                        BoxShadow(
                                          color: AppColors.grey.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 2,
                                          offset: const Offset(0, -3),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(15.sp),
                                    child: MySvgWidget(
                                      path: AppIcons.dateTrip,
                                      height: 25.sp,
                                      width: 25.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (cubit.homeModel?.data?.user?.isActive == 1 &&
                            cubit.homeModel?.data?.currentTrip != null) ...[
                          CustomsSheduledTripWidet(
                            trip: cubit.homeModel?.data?.currentTrip,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class CustomsSheduledTripWidet extends StatelessWidget {
  const CustomsSheduledTripWidet({super.key, this.trip});
  final DriverTripModel? trip;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      // bottom: false,
      child: Padding(
        padding: EdgeInsets.only(top: 15.h),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
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
          padding: EdgeInsets.all(15.sp),
          child: Column(
            children: [
              FromToContainer(
                isFrom: true,
                address: trip?.from,
                lat: trip?.fromLat,
                lng: trip?.fromLong,
              ),

              8.h.verticalSpace,
              FromToContainer(
                isFrom: false,
                address: trip?.to,
                lat: trip?.toLat,
                lng: trip?.toLong,
              ),
              if (trip?.description != null &&
                  trip!.description!.isNotEmpty) ...[
                12.h.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.second3Primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.all(12.sp),
                  width: double.infinity,
                  child: Text(
                    trip?.description ?? "",
                    style: getMediumStyle(fontSize: 12.sp),
                  ),
                ),
              ],
              20.h.verticalSpace,
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: CustomButton(title: "chat_with_client".tr()),
                  ),
                  20.w.horizontalSpace,
                  Flexible(
                    flex: 1,
                    child: CustomButton(
                      title: "reject".tr(),
                      btnColor: AppColors.secondPrimary,
                      textColor: AppColors.primary,
                      onPressed: () {
                        warningDialog(
                          context,
                          title: "are_you_sure_you_want_to_reject_trip".tr(),
                          onPressedOk: () {
                            context
                                .read<DriverHomeCubit>()
                                .cancleCurrentShipment(
                                  tripId: trip?.id ?? 0,
                                  context: context,
                                );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              CustomButton(
                title: "start_trip".tr(),
                // btnColor: AppColors.secondPrimary,
                // textColor: AppColors.primary,
              ),

              CustomButton(
                title: "end_trip".tr(),
                btnColor: AppColors.red,
                textColor: AppColors.white,
              ),

              80.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class FromToContainer extends StatelessWidget {
  const FromToContainer({
    super.key,
    required this.isFrom,
    this.address,
    this.lat,
    this.lng,
  });
  final bool isFrom;
  final String? address;
  final String? lat;
  final String? lng;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log('lat: $lat, lng: $lng');
        if (lat != null && lng != null) {
          context.read<LocationCubit>().openGoogleMapsRoute(
            double.tryParse(lat ?? '0') ?? 0,
            double.tryParse(lng ?? '0') ?? 0,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondPrimary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.all(12.sp),
        width: double.infinity,
        child: RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          text: TextSpan(
            children: [
              TextSpan(
                text: isFrom ? '${'from'.tr()}: ' : '${'to'.tr()}: ',
                style: getBoldStyle(fontSize: 16.sp, color: AppColors.primary),
              ),
              TextSpan(
                text: address ?? "",
                style: getMediumStyle(fontSize: 12.sp, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
