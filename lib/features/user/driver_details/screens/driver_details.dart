import 'dart:developer';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_divider.dart';
import 'package:waslny/extention.dart';
import 'package:waslny/features/user/driver_details/cubit/cubit.dart';
import 'package:waslny/features/user/driver_details/cubit/state.dart';
import 'package:waslny/features/user/driver_details/data/model/driver_details_model.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/call_message.dart';
// اعمل Import لملف الموديلز اللي فوق

// --- تعريف الألوان المستخدمة ---

class DriverProfileScreen extends StatefulWidget {
  final String driverId;
  final String? tripId;
  final String? shipmentCode;
  const DriverProfileScreen({
    super.key,
    required,
    required this.driverId,
    required this.tripId,
    required this.shipmentCode,
  });

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  @override
  void initState() {
    context.read<DriverDetailsCubit>().getDriverById(widget.driverId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<DriverDetailsCubit, DriverDetailsState>(
        builder: (context, state) {
          var cubit = context.read<DriverDetailsCubit>();
          var driverData = cubit.driverDetailsModel?.data;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: Text('driver_details'.tr())),
            body: SafeArea(
              top: false,
              child: state is DriverDetailsLoading
                  ? const Center(child: CustomLoadingIndicator())
                  : SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.second2Primary,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            //! done
                            Container(
                              // margin: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10.r),
                                  bottomLeft: Radius.circular(10.r),
                                ),
                              ),
                              child: _buildHeader(
                                context,
                                driverData,
                                widget.tripId,
                                widget.shipmentCode,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.second2Primary,
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                children: [
                                  // --- الجزء الثاني: تفاصيل الكابتن ---
                                  _buildDriverDetails(context, driverData),

                                  // --- الجزء الثالث: التقييمات ---
                                  _buildReviewsSection(
                                    context,
                                    driverData?.rates,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  /// --- الويدجت الخاص بالـ Header ---
  Widget _buildHeader(
    BuildContext context,
    DriverProfileMainModelData? driver,
    String? tripId,
    String? shipmentCode,
  ) {
    // تحويل التقييم من String لـ double
    double rating = double.tryParse(driver?.avgRate.toString() ?? '0.0') ?? 0.0;
    log(driver?.name ?? '');
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0.w, 40.h, 0.w, 0.h),
          height: 120.h,
          width: context.w,
          child: Column(
            children: [
              Container(
                height: 120.h,
                width: context.w,
                decoration: BoxDecoration(
                  color: AppColors.secondPrimary,
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                ),
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      driver?.name.toString() ?? '',
                      style: getMediumStyle(color: AppColors.white),
                      maxLines: 2,
                    ),
                    Text(
                      driver?.phone ?? '',
                      style: getRegularStyle(color: AppColors.second5Primary),
                    ),

                    Flexible(
                      fit: FlexFit.tight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: CustomCallAndMessageWidget(
                              phoneNumber: driver?.phone ?? '',
                              driverId: driver?.id.toString() ?? '',
                              name: driver?.name ?? '',
                              tripId: tripId,
                              shipmentCode: shipmentCode,
                            ),
                          ),
                          5.w.horizontalSpace,
                          Text(
                            driver?.avgRate.toString() ?? '0.0',
                            maxLines: 1,
                            style: getRegularStyle(color: AppColors.white),
                          ),
                          5.w.horizontalSpace,

                          RatingBarIndicator(
                            rating: rating,
                            itemBuilder: (context, index) =>
                                Icon(Icons.star, color: AppColors.primary),
                            itemCount: 5,
                            itemSize: 18.sp,
                            unratedColor: AppColors.second2Primary,
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PositionedDirectional(
          end: 32.h,
          top: 10.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(radius: 44.r, backgroundColor: AppColors.primary),
              CircleAvatar(
                radius: 40.r,

                backgroundImage: NetworkImage(driver?.image ?? ''),

                onBackgroundImageError: (exception, stackTrace) => {},
                backgroundColor: AppColors.second2Primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverDetails(
    BuildContext context,
    DriverProfileMainModelData? driver,
  ) {
    // ⭐️ بنبني الداتا هنا من الموديل مباشرة
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          // التصميم كان فيه رقم تليفون تاني، لو هو نفسه هنستخدمه
          _buildDetailRow('phone_number'.tr(), driver?.phone ?? 'N/A'),
          _buildDetailRow('type'.tr(), driver?.genderName ?? 'N/A'),
          _buildDetailRow(
            'vehicle_type'.tr(),
            driver?.vehicleModel ?? '',
          ), // دي كانت Hardcoded في التصميم
          _buildDetailRow(
            'details'.tr(),
            driver?.vehicleModel?.toString() ?? 'N/A',
          ),
          _buildDetailRow(
            'color'.tr(),
            driver?.vehicleColor?.toString() ?? 'N/A',
          ),
          _buildDetailRow(
            'vehicle_plate_number'.tr(),
            driver?.vehiclePlateNumber?.toString() ?? 'N/A',
          ),
          _buildDetailRow('trips_no'.tr(), driver?.trips?.toString() ?? '0'),
        ],
      ),
    );
  }

  // (ويدجت سطر التفاصيل زي ما هو)
  Widget _buildDetailRow(String title, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: getSemiBoldStyle(
                  color: AppColors.secondPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: getMediumStyle(
                  color: AppColors.secondPrimary,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        CustomDivider(color: AppColors.white, endIndent: 0, indent: 0),
      ],
    );
  }

  /// --- الويدجت الخاص بالتقييمات ---
  Widget _buildReviewsSection(BuildContext context, List<RateModel>? rates) {
    // ⭐️ بنضيف Check لو الـ rates فاضية أو null
    if (rates == null || rates.isEmpty) {
      return Container(
        width: double.infinity,

        padding: EdgeInsets.only(bottom: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'rates'.tr(),
              style: getBoldStyle(color: AppColors.secondPrimary),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Text(
                'no_rates'.tr(),
                style: TextStyle(color: Colors.grey[600], fontSize: 15.sp),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,

      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'rates'.tr(),
            style: getBoldStyle(color: AppColors.secondPrimary),
          ),

          ListView.builder(
            itemCount: rates.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildReviewCard(rates[index]);
            },
          ),
        ],
      ),
    );
  }

  // ويدجت صغيرة لكارت التقييم
  Widget _buildReviewCard(RateModel review) {
    // ⭐️ تم التعديل ليناسب الـ RateModel
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.second4Primary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(radius: 22.r, backgroundColor: AppColors.primary),
              CircleAvatar(
                radius: 20.w,
                // ⭐️ استخدام NetworkImage
                backgroundImage: NetworkImage(review.image ?? ''),
                backgroundColor: AppColors.second2Primary,
              ),
            ],
          ),
          Flexible(
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          (review.user ?? 'مستخدم'), // من الموديل
                          style: getMediumStyle(fontSize: 16.sp),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          (review.comment ?? 'لا يوجد تعليق'), // من الموديل
                          style: getRegularStyle(
                            fontSize: 12.sp,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
            ),
          ),
          // التاريخ (محتاج تعمل format لو حابب)
          Text(
            review.createdAt ?? 'منذ فترة',
            maxLines: 1, // استخدم الداتا من الموديل
            style: getRegularStyle(
              color: AppColors.secondPrimary,
              fontSize: 12.sp,
            ),
          ),

          // الصورة والاسم والتقييم
        ],
      ),
    );
  }
}
