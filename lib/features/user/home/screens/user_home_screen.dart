import 'dart:developer';

import 'package:flutter_svg/svg.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/core/utils/user_info.dart';
import 'package:waslny/features/user/add_new_trip/screens/add_new_trip.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/trip_and_service_widget.dart';
import 'package:escapable_padding/escapable_padding.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    // if (context.read<UserHomeCubit>().homeModel == null)
    context.read<UserHomeCubit>().getHome(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeCubit, UserHomeState>(
      builder: (context, state) {
        var cubit = context.read<UserHomeCubit>();

        return SafeArea(
          child: Scaffold(
            body: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await cubit.getHome(context);
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: getHorizontalPadding(context),
                      right: getHorizontalPadding(context),
                    ),
                    child: CustomUserInfo(),
                  ), //! done
                  10.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.only(
                      left: getHorizontalPadding(context),
                      right: getHorizontalPadding(context),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomMainContainer(
                            isPng: true,
                            image: ImageAssets.addShipment,
                            title: "add_trip".tr(),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.addNewTripRoute,
                                arguments: AddTripArgs(isService: false),
                              );
                            },
                          ),
                        ),
                        20.w.horizontalSpace,
                        Expanded(
                          child: CustomMainContainer(
                            image: AppIcons.addServiceIcon,
                            title: "add_service".tr(),
                            onTap: () {
                              //!
                              Navigator.pushNamed(
                                context,
                                Routes.addNewTripRoute,
                                arguments: AddTripArgs(isService: true),
                              );
                              log('Ad add_service');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.h.verticalSpace,
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: getHorizontalPadding(context),
                        right: getHorizontalPadding(context),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                        color: AppColors.second3Primary,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [
                              //! change to dropdown with types ENUM
                              Expanded(
                                child:
                                    CustomDropdownButtonFormField<ServicesType>(
                                      items: ServicesType.values,
                                      itemBuilder: (item) => item.displayValue,
                                      value: cubit.serviceType,
                                      fillColor: AppColors.second3Primary,

                                      onChanged: (value) {
                                        setState(() {
                                          cubit.serviceType = value;
                                          cubit.getHome(context);
                                        });
                                      },
                                    ),
                              ),

                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.allTripsScreenRoute,
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "all".tr(),
                                        style: getRegularStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.secondPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                child: state is UserHomeError
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
                                        child: CustomLoadingIndicator(),
                                      )
                                    : ((cubit
                                                  .homeModel
                                                  ?.data
                                                  ?.services
                                                  ?.isEmpty ==
                                              true &&
                                          cubit.serviceType?.name ==
                                              ServicesType.services.name))
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 100.h),
                                        child: CustomNoDataWidget(
                                          message: 'no_serices'.tr(),
                                          onTap: () {
                                            cubit.getHome(context);
                                          },
                                        ),
                                      )
                                    : (cubit.homeModel?.data?.trips?.isEmpty ==
                                              true &&
                                          cubit.serviceType?.name ==
                                              ServicesType.trips.name)
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
                                        padding: EdgeInsets.only(
                                          bottom:
                                              (kBottomNavigationBarHeight + 5)
                                                  .h,
                                        ),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) =>
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 3.w,
                                                vertical: 3.h,
                                              ),
                                              child: TripOrServiceItemWidget(
                                                tripOrService:
                                                    (cubit.serviceType?.name
                                                            .toString() ==
                                                        ServicesType.trips.name
                                                            .toString())
                                                    ? cubit
                                                          .homeModel!
                                                          .data!
                                                          .trips![index]
                                                    : cubit
                                                          .homeModel!
                                                          .data!
                                                          .services?[index],
                                              ),
                                            ),
                                        separatorBuilder: (context, index) =>
                                            20.h.verticalSpace,
                                        itemCount:
                                            (cubit.serviceType?.name ==
                                                ServicesType.trips.name
                                            ? (cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.trips
                                                      ?.length ??
                                                  0)
                                            : (cubit
                                                      .homeModel
                                                      ?.data
                                                      ?.services
                                                      ?.length ??
                                                  0)),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomMainContainer extends StatelessWidget {
  const CustomMainContainer({
    super.key,
    required this.image,
    required this.title,
    this.onTap,
    this.isPng = false,
  });
  final String image;
  final bool? isPng;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondPrimary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 5.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            isPng == true
                ? Image.asset(image, height: 55.h, width: 55.h)
                : SvgPicture.asset(image, height: 55.h, width: 55.h),
            Flexible(
              child: AutoSizeText(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 14.sp,
                style: getSemiBoldStyle(
                  fontSize: 16.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
