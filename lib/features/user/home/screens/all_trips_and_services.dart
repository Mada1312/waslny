import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/extention.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/cubit/state.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/trip_and_service_widget.dart';

class AllTripsScreenRoute extends StatefulWidget {
  const AllTripsScreenRoute({super.key});

  @override
  State<AllTripsScreenRoute> createState() => _AllTripsScreenRouteState();
}

class _AllTripsScreenRouteState extends State<AllTripsScreenRoute> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeCubit, UserHomeState>(
      builder: (context, state) {
        var cubit = context.read<UserHomeCubit>();
        return Scaffold(
          appBar: AppBar(title: Text('all'.tr())),

          body: Column(
            children: [
              Flexible(
                child: Container(
                  width: context.w,
                  padding: EdgeInsets.only(
                    left: getHorizontalPadding(context),

                    right: getHorizontalPadding(context),
                  ),
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    color: AppColors.second3Primary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      SizedBox(
                        width: context.w / 2,
                        child: CustomDropdownButtonFormField<ServicesType>(
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
                                : ((cubit.homeModel?.data?.services?.isEmpty ==
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
                                          (kBottomNavigationBarHeight + 5).h,
                                    ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => Padding(
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
        );
      },
    );
  }
}
