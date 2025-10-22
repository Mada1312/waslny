import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:waslny/core/exports.dart';

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
    if (context.read<DriverHomeCubit>().homeModel == null)
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
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => context.read<DriverHomeCubit>().changeStep(),
          child: Icon(Icons.add, color: AppColors.white),
        ),
      ),
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
          DriverHomeUI(),
        ],
      ),
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
        return Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),

                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16.r),
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
                          padding: EdgeInsets.symmetric(
                            // vertical: 8.h,
                            horizontal: 15.w,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  cubit.isOnline
                                      ? "online".tr()
                                      : "offline".tr(),
                                  style: getBoldStyle(fontSize: 18.sp),
                                ),
                              ),
                              CupertinoSwitch(
                                value: cubit.isOnline,

                                activeTrackColor: AppColors.secondPrimary,

                                inactiveThumbColor: AppColors.white,
                                thumbColor: AppColors.primary,
                                onChanged: (value) {
                                  cubit.changeOnlineStatus();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      12.w.horizontalSpace,
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
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
                    ],
                  ),
                ),
              ),
            ),

            if (cubit.isOnline && cubit.step == 1) Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),

              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (cubit.step == 0)
                      Expanded(child: Container())
                    else
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16.r),
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
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  "scheduled".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: getBoldStyle(fontSize: 14.sp),
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
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(DateTime.now()),
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
                                    '10:00',
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

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16.r),
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
                      child: MySvgWidget(
                        path: AppIcons.dateTrip,
                        height: 25.sp,
                        width: 25.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (cubit.isOnline && cubit.step == 1) ...[
              CustomsSheduledTripWidet(),
            ],
          ],
        );
      },
    );
  }
}

class CustomsSheduledTripWidet extends StatelessWidget {
  const CustomsSheduledTripWidet({super.key});

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
              FromToContainer(),

              8.h.verticalSpace,
              FromToContainer(),
              12.h.verticalSpace,
              Container(
                decoration: BoxDecoration(
                  color: AppColors.second3Primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.all(12.sp),
                width: double.infinity,
                child: Text(
                  "detaislss " * 50,
                  style: getMediumStyle(fontSize: 12.sp),
                ),
              ),
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
                      title: "start_trip".tr(),
                      btnColor: AppColors.secondPrimary,
                      textColor: AppColors.primary,
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
  const FromToContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                text: '${'from'.tr()}: ',
                style: getBoldStyle(fontSize: 16.sp, color: AppColors.primary),
              ),
              TextSpan(
                text:
                    'القاهرة الجديدة - التجمع الخامس - النرجس الجديدة - طريق بلا ع' *
                    3,
                style: getMediumStyle(fontSize: 12.sp, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
