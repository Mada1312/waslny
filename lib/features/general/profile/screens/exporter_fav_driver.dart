// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/core/widgets/custom_divider.dart';
import 'package:waslny/extention.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/cubit/state.dart';

import '../../../../core/utils/call_method.dart';

class UserFavTripsAndServices extends StatefulWidget {
  const UserFavTripsAndServices({super.key});

  @override
  State<UserFavTripsAndServices> createState() =>
      _UserFavTripsAndServicesState();
}

class _UserFavTripsAndServicesState extends State<UserFavTripsAndServices> {
  @override
  void initState() {
    context.read<ProfileCubit>().getMainFavUserTripsAndServices(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeCubit, UserHomeState>(
      builder: (context, state) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            var cubit = context.read<ProfileCubit>();
            return Scaffold(
              appBar: AppBar(title: Text('favorites'.tr())),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: context.w / 2,
                      child: CustomDropdownButtonFormField<ServicesType>(
                        items: ServicesType.values,

                        itemBuilder: (item) => item.displayValue,
                        value: context.read<UserHomeCubit>().serviceType,
                        fillColor: AppColors.second2Primary,

                        onChanged: (value) {
                          setState(() {
                            context.read<UserHomeCubit>().serviceType = value;
                            cubit.getMainFavUserTripsAndServices(context);
                          });
                        },
                      ),
                    ),
                    5.h.verticalSpace,
                    Flexible(
                      fit: FlexFit.tight,
                      child:
                          (state is LoadingContactUsState &&
                              cubit.mainFavModel == null)
                          ? Center(child: CustomLoadingIndicator())
                          : ((cubit.mainFavModel?.data?.services?.length ==
                                    0) &&
                                context
                                        .read<UserHomeCubit>()
                                        .serviceType
                                        ?.name ==
                                    ServicesType.services.name)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MySvgWidget(path: AppIcons.noDataIcon),
                                  Text('no_serices'.tr()),
                                ],
                              ),
                            )
                          : ((cubit.mainFavModel?.data?.trips?.length == 0) &&
                                context
                                        .read<UserHomeCubit>()
                                        .serviceType
                                        ?.name ==
                                    ServicesType.trips.name)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MySvgWidget(path: AppIcons.noDataIcon),
                                  Text('no_trips'.tr()),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount:
                                  (context
                                          .read<UserHomeCubit>()
                                          .serviceType
                                          ?.name ==
                                      ServicesType.trips.name)
                                  ? cubit.mainFavModel!.data!.trips!.length
                                  : cubit.mainFavModel!.data!.services!.length,

                              itemBuilder: (context, index) {
                                var trip =
                                    ((context
                                            .read<UserHomeCubit>()
                                            .serviceType
                                            ?.name ==
                                        ServicesType.trips.name)
                                    ? cubit.mainFavModel!.data!.trips!
                                    : cubit
                                          .mainFavModel!
                                          .data!
                                          .services!)[index];
                                return Container(
                                  margin: EdgeInsets.all(5.w),
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.second2Primary,

                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trip.from ?? '',
                                          maxLines: 2,
                                          style: getSemiBoldStyle(
                                            fontSize: 14.sp,
                                            fontweight: FontWeight.w600,
                                          ),
                                        ),

                                        Text(
                                          trip.serviceToName != null
                                              ? trip.serviceToName ?? ''
                                              : trip.to ?? '',
                                          style: getRegularStyle(
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        10.h.verticalSpace,

                                        Row(
                                          children: [
                                            10.h.horizontalSpace,
                                            Expanded(
                                              child: CustomButton(
                                                title: 'make_trip'.tr(),
                                                radius: 10.r,
                                                onPressed: () {
                                                  customTripAndServiceCloneDialog(
                                                    controller: cubit
                                                        .selectedDateTimeController,
                                                    isSchedule: false,

                                                    context,
                                                    btnOkText: 'confirm'.tr(),

                                                    title: 'sure_to_make_trip'
                                                        .tr(),
                                                    onPressedOk: () {
                                                      cubit.cloneTrip(
                                                        isSchedule: false,
                                                        trip.id?.toString() ??
                                                            '',
                                                        context: context,
                                                      );
                                                    },
                                                  );
                                                },
                                                textColor: AppColors.primary,
                                                padding: EdgeInsets.all(5),
                                                btnColor:
                                                    AppColors.secondPrimary,
                                              ),
                                            ),
                                            5.h.horizontalSpace,
                                            Expanded(
                                              child: CustomButton(
                                                title: 'make_schedule_trip'
                                                    .tr(),
                                                radius: 10.r,
                                                textColor: AppColors.primary,
                                                onPressed: () {
                                                  customTripAndServiceCloneDialog(
                                                    controller: cubit
                                                        .selectedDateTimeController,
                                                    isSchedule: true,
                                                    onTap: () {
                                                      cubit.selectDateTime(
                                                        context,
                                                      );
                                                    },
                                                    context,
                                                    btnOkText: 'confirm'.tr(),

                                                    title:
                                                        'sure_to_make_schedule_trip'
                                                            .tr(),
                                                    onPressedOk: () {
                                                      cubit.cloneTrip(
                                                        isSchedule: true,
                                                        trip.id?.toString() ??
                                                            '',
                                                        context: context,
                                                      );
                                                    },
                                                  );
                                                },
                                                padding: EdgeInsets.all(5),
                                                btnColor:
                                                    AppColors.secondPrimary,
                                              ),
                                            ),
                                            5.h.horizontalSpace,

                                            InkWell(
                                              onTap: () {
                                                warningDialog(
                                                  context,
                                                  btnOkText: 'delete'.tr(),

                                                  title: 'remove_from_fav'.tr(),
                                                  onPressedOk: () {
                                                    cubit.actionFav(
                                                      trip.id?.toString() ?? '',
                                                      context: context,
                                                    );
                                                  },
                                                );
                                                //! remove form fav
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.secondPrimary,

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.r,
                                                      ),
                                                ),
                                                child: Icon(
                                                  Icons.favorite_rounded,
                                                  color: trip.isFav == true
                                                      ? AppColors.primary
                                                      : AppColors.white,
                                                ),
                                              ),
                                            ),
                                            10.h.horizontalSpace,
                                          ],
                                        ),
                                        10.h.verticalSpace,
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
