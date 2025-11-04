import 'dart:async';
import 'dart:developer' show log;
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/driver/home/screens/widgets/custom_current_trip_widget.dart';
import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/profile/screens/profile_screen.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  StreamSubscription? _fcmSubscription;

  @override
  void initState() {
    super.initState();

    context.read<DriverHomeCubit>().getDriverHomeData(context);

    _fcmSubscription = FirebaseMessaging.onMessage.listen((message) async {
      if (!mounted) return;

      context.read<DriverHomeCubit>().getDriverHomeData(context);
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
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
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        var cubit = context.read<DriverHomeCubit>();
        return RefreshIndicator(
          color: AppColors.primary,
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
                  ? Center(
                      child: CustomLoadingIndicator(color: AppColors.primary),
                    )
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

                                          state is LoadingChangeOnlineStatusState
                                              ? CircularProgressIndicator(
                                                  color:
                                                      AppColors.secondPrimary,
                                                )
                                              : CupertinoSwitch(
                                                  value:
                                                      cubit
                                                          .homeModel
                                                          ?.data
                                                          ?.user
                                                          ?.isActive ==
                                                      1,

                                                  activeTrackColor:
                                                      AppColors.secondPrimary,

                                                  inactiveThumbColor:
                                                      AppColors.white,
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ProfileScreen(
                                              isDriver: true,
                                            );
                                          },
                                        ),
                                      );
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
