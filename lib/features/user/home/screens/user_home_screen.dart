import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/core/utils/get_route_distance.dart';
import 'package:waslny/core/utils/user_info.dart';
import 'package:waslny/features/general/price/pricing_widget.dart';
import 'package:waslny/features/user/add_new_trip/screens/add_new_trip.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/trip_and_service_widget.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import 'package:waslny/features/general/price/pricing_engine.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserHomeCubit>().getHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserHomeCubit, UserHomeState>(
      // listener: (context, state) async {
      //   if (state is TripEndedState) {
      //     log('🚀 TripCompletedState detected, showing dialogs...');

      //     final trip = state.trip;
      //     final tripId = trip.id?.toString() ?? '';

      //     await _showTripDetailsDialog(context, trip);

      //     if (context.mounted) {
      //       _showRatingDialog(context, trip, tripId);
      //     }
      //   }
      // },
      listener: (context, state) async {
        if (state is TripEndedState) {
          final trip = state.trip;
          final tripId = trip.id?.toString() ?? '';

          if (trip.isService != 1) {
            await _showTripDetailsDialog(context, trip);
          }

          if (context.mounted) {
            _showRatingDialog(context, trip, tripId);
          }
        }
      },

      child: BlocBuilder<UserHomeCubit, UserHomeState>(
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
                      padding: EdgeInsets.symmetric(
                        horizontal: getHorizontalPadding(context),
                      ),
                      child: CustomUserInfo(),
                    ),
                    10.h.verticalSpace,
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getHorizontalPadding(context),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: getHorizontalPadding(context),
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
                              children: [
                                Expanded(
                                  child:
                                      CustomDropdownButtonFormField<
                                        ServicesType
                                      >(
                                        items: ServicesType.values,
                                        itemBuilder: (item) =>
                                            item.displayValue,
                                        value: cubit.serviceType,
                                        fillColor: AppColors.second3Primary,
                                        onChanged: (value) async {
                                          cubit.serviceType = value!;
                                          await cubit.getHome(context);
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
                                          message: 'Welcome to waslny'.tr(),
                                          onTap: () {
                                            cubit.getHome(context);
                                          },
                                        ),
                                      )
                                    : ListView.separated(
                                        key: ValueKey(
                                          '${cubit.serviceType?.name}_${cubit.homeModel?.data?.trips?.length}_${cubit.homeModel?.data?.services?.length}',
                                        ),
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
                                                    (cubit.serviceType?.name ==
                                                        ServicesType.trips.name)
                                                    ? cubit
                                                          .homeModel!
                                                          .data!
                                                          .trips![index]
                                                    : cubit
                                                          .homeModel!
                                                          .data!
                                                          .services![index],
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
      ),
    );
  }

  Future<void> _showTripDetailsDialog(
    BuildContext context,
    TripAndServiceModel trip,
  ) async {
    log('🚀 Showing trip details dialog');

    // ─────────────────────────────────────────────
    // 1️⃣ Parse coordinates safely
    // ─────────────────────────────────────────────
    final fromLat = double.tryParse(trip.fromLat ?? '0');
    final fromLng = double.tryParse(trip.fromLong ?? '0');
    final toLat = double.tryParse(trip.toLat ?? '0');
    final toLng = double.tryParse(trip.toLong ?? '0');

    log('📍 CLIENT PARSED COORDS:');
    log('  fromLat: $fromLat');
    log('  fromLng: $fromLng');
    log('  toLat  : $toLat');
    log('  toLng  : $toLng');

    // ─────────────────────────────────────────────
    // 2️⃣ Validate coordinates (مهم جدًا)
    // ─────────────────────────────────────────────
    if (fromLat == null ||
        fromLng == null ||
        toLat == null ||
        toLng == null ||
        fromLat == 0.0 ||
        fromLng == 0.0 ||
        toLat == 0.0 ||
        toLng == 0.0) {
      log('❌ Invalid trip coordinates');
      if (context.mounted) {
        errorGetBar("تعذر تحديد موقع الرحلة");
      }
      return;
    }

    final isFemaleDriver = trip.driver?.userType == '2';

    // ─────────────────────────────────────────────
    // 3️⃣ Get route-based distance (OSRM)
    // ─────────────────────────────────────────────
    final distanceKm = await getRouteDistance(fromLat, fromLng, toLat, toLng);

    if (distanceKm == null) {
      log('❌ Failed to calculate route distance');
      if (context.mounted) {
        errorGetBar("تعذر حساب مسافة الرحلة");
      }
      return;
    }

    log('📏 CLIENT distanceKm (OSRM): $distanceKm');

    if (!context.mounted) return;

    // ─────────────────────────────────────────────
    // 4️⃣ Calculate price (same rules as captain)
    // ─────────────────────────────────────────────
    final tripPrice = PricingEngine.calculateTripPrice(
      distanceKm: distanceKm,
      isFemaleDriver: isFemaleDriver,
    );

    log('💰 CLIENT tripPrice: $tripPrice');
    log('═══════════════════════════════════');

    // ─────────────────────────────────────────────
    // 5️⃣ Show confirmation dialog
    // ─────────────────────────────────────────────
    await showPaymentConfirmationDialog(
      context,
      tripPrice: tripPrice,
      distanceKm: distanceKm,
      isFemaleDriver: isFemaleDriver,
      onPaymentConfirmed: () {
        log('✅ Payment confirmed for trip ${trip.id}');
      },
    );
  }

  void _showRatingDialog(
    BuildContext context,
    TripAndServiceModel trip,
    String tripId,
  ) {
    log('🚀 Showing rating dialog');
    if (!context.mounted) return;

    final cubit = context.read<UserHomeCubit>();
    cubit.rateValue = 3.0;
    cubit.rateCommentController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // اسم السائق
              Text(
                trip.driver?.name ?? "كابتن غير معروف",
                style: getSemiBoldStyle(fontSize: 16.sp),
              ),

              20.h.verticalSpace,

              // صورة السائق
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child:
                    trip.driver?.image != null && trip.driver!.image!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          trip.driver!.image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person, size: 50),
              ),

              15.h.verticalSpace,

              // النجوم
              RatingBar.builder(
                initialRating: cubit.rateValue,
                minRating: 1,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) =>
                    Icon(Icons.star, color: AppColors.primary),
                onRatingUpdate: (rating) {
                  cubit.rateValue = rating;
                },
              ),

              15.h.verticalSpace,

              Text(
                "${cubit.rateValue.toStringAsFixed(1)} من 5",
                style: getRegularStyle(
                  fontSize: 14.sp,
                  color: AppColors.secondPrimary,
                ),
              ),

              20.h.verticalSpace,

              TextField(
                controller: cubit.rateCommentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "اكتب تعليقك (اختياري)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),

              20.h.verticalSpace,

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (!context.mounted) return;
                        await context.read<UserHomeCubit>().getHome(context);
                      },
                      child: Text("تخطي"),
                    ),
                  ),
                  10.w.horizontalSpace,
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        cubit.addRateForDriver(
                          context: context,
                          tripId: trip.id!.toString(),
                        );
                      },
                      child: Text("إرسال"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
