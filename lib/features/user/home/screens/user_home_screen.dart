import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/user_info.dart';
import 'package:waslny/features/user/add_new_shipment/screens/add_new_shipment.dart';
import 'package:waslny/features/user/home/screens/custom_slider.dart';
import 'package:waslny/features/user/shipments/cubit/cubit.dart';
import 'package:waslny/features/user/shipments/screens/widgets/shipment_widget.dart';
import 'package:escapable_padding/escapable_padding.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({
    super.key,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    if (context.read<UserHomeCubit>().homeModel == null)
      context.read<UserHomeCubit>().getHome(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeCubit, UserHomeState>(builder: (context, state) {
      var cubit = context.read<UserHomeCubit>();

      return SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              ///!
              //>>New Header
              SizedBox(
                height: getHeightSize(context) / 4,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      // borderRadius: BorderRadius.only(
                      //   bottomLeft: Radius.circular(20.sp),
                      //   bottomRight: Radius.circular(20.sp),
                      // ),
                      child: Image.asset(
                        ImageAssets.userCover,
                        fit: BoxFit.cover,
                        height: getHeightSize(context) / 4,
                        width: double.infinity,
                      ),
                    ),
                    //! Shadow of image
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondPrimary.withOpacity(0.8),
                        // borderRadius: BorderRadius.only(
                        //   // bottomLeft: Radius.circular(20.sp),
                        //   // bottomRight: Radius.circular(20.sp),
                        // ),
                      ),
                    ),
                    CarouselWithLineIndicator(),
                    Container(
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.sp),
                          topRight: Radius.circular(20.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ///!

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: getHorizontalPadding(context),
                    right: getHorizontalPadding(context),
                  ),
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      await cubit.getHome(context);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          CustomUserInfo(),
                          20.h.verticalSpace,
                          Row(
                            children: [
                              Expanded(
                                child: CustomMainContainer(
                                  image: ImageAssets.addShipment,
                                  title: "add_trip".tr(),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.addNewShipmentRoute,
                                        arguments: AddShipmentsArgs());
                                  },
                                ),
                              ),
                              20.w.horizontalSpace,
                              Expanded(
                                child: CustomMainContainer(
                                  image: ImageAssets.currentShipment,
                                  title: "current_trips".tr(),
                                  onTap: () {
                                    context
                                        .read<UserShipmentsCubit>()
                                        .changeSelectedStatus(
                                            ShipmentsStatusEnum.pending);
                                    Navigator.pushNamed(
                                      context,
                                      Routes.userShipmentsRoute,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          20.h.verticalSpace,
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
                                        maxLines: 1,
                                        style: getSemiBoldStyle(
                                          fontSize: 18.sp,
                                          color: AppColors.primary,
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
                                        "${"trips_count".tr()}${cubit.homeModel?.data?.totalShipments.toString() ?? "0"}",
                                        maxLines: 1,
                                        style: getSemiBoldStyle(
                                          fontSize: 18.sp,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          20.h.verticalSpace,
                          Row(
                            children: [
                              Text(
                                "new_trips".tr(),
                                style: getSemiBoldStyle(
                                  fontSize: 16.sp,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  context
                                      .read<UserShipmentsCubit>()
                                      .changeSelectedStatus(
                                          ShipmentsStatusEnum.newShipments);
                                  Navigator.pushNamed(
                                    context,
                                    Routes.userShipmentsRoute,
                                  );
                                },
                                child: Text(
                                  "all".tr(),
                                  style: getSemiBoldStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.secondPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          20.h.verticalSpace,
                          state is UserHomeError
                              ? CustomNoDataWidget(
                                  message: 'error_happened'.tr(),
                                  onTap: () {
                                    cubit.getHome(context);
                                  },
                                )
                              : state is UserHomeLoading ||
                                      cubit.homeModel?.data == null
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 150.h),
                                      child: CustomLoadingIndicator())
                                  : cubit.homeModel?.data?.shipments?.isEmpty ==
                                          true
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 100.h),
                                          child: CustomNoDataWidget(
                                            message: 'no_trips'.tr(),
                                            onTap: () {
                                              cubit.getHome(context);
                                            },
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) =>
                                              Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 3.w,
                                              vertical: 3.h,
                                            ),
                                            child: ShipmentItemWidget(
                                              shipment: cubit.homeModel?.data
                                                  ?.shipments?[index],
                                            ),
                                          ),
                                          separatorBuilder: (context, index) =>
                                              20.h.verticalSpace,
                                          itemCount: cubit.homeModel?.data
                                                  ?.shipments?.length ??
                                              0,
                                        ),
                          20.h.verticalSpace,
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class CustomMainContainer extends StatelessWidget {
  const CustomMainContainer({
    super.key,
    required this.image,
    required this.title,
    this.onTap,
  });
  final String image;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: 15.w,
        ),
        child: Column(
          children: [
            Image.asset(
              image,
              height: 55.h,
              width: 55.h,
            ),
            8.h.verticalSpace,
            AutoSizeText(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 10.sp,
              style: getRegularStyle(
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
