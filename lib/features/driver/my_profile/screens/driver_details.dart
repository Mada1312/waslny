import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_divider.dart';
import 'package:waslny/extention.dart';
import 'package:waslny/features/driver/my_profile/data/model/driver_details_model.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class DriverDetailsScreen extends StatefulWidget {
  const DriverDetailsScreen({super.key, required});

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  @override
  void initState() {
    context.read<DriverProfileCubit>().getDriverDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<DriverProfileCubit, DriverProfileState>(
        builder: (context, state) {
          var cubit = context.read<DriverProfileCubit>();
          var driverData = cubit.driverDetailsModel?.data;
          return Scaffold(
            body: SafeArea(
              top: false,
              child: state is DriverDetailsLoading && driverData == null
                  ? const Center(child: CustomLoadingIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          50.h.verticalSpace,
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.editDeliveryProfileRoute,
                              );
                            },
                            child: Image.asset(
                              ImageAssets.driverEdit,
                              height: 80.sp,
                              width: 80.sp,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.second2Primary,
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              children: [
                                Container(
                                  // margin: EdgeInsets.symmetric(horizontal: 16.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10.r),
                                      bottomLeft: Radius.circular(10.r),
                                    ),
                                  ),
                                  child: _buildHeader(context, driverData),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.second2Primary,
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  child: Column(
                                    children: [
                                      _buildDriverDetails(context, driverData),

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
                          kBottomNavigationBarHeight.h.verticalSpace,
                        ],
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
  ) {
    double rating = double.tryParse(driver?.avgRate.toString() ?? '0.0') ?? 0.0;

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
                      style: getMediumStyle(
                        color: AppColors.primary,
                        fontSize: 24.sp,
                      ),
                      maxLines: 2,
                    ),

                    Flexible(
                      fit: FlexFit.tight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              driver?.phone ?? '',
                              style: getRegularStyle(
                                color: AppColors.second5Primary,
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              5.w.horizontalSpace,
                              Text(
                                '${driver?.percentage.toString() ?? '0'}%',
                                maxLines: 1,
                                style: getRegularStyle(color: AppColors.white),
                              ),
                              5.w.horizontalSpace,
                              MySvgWidget(
                                path: AppIcons.percentage,
                                width: 16.w,
                                height: 16.h,
                              ),
                              10.w.horizontalSpace,
                              Text(
                                driver?.avgRate.toString() ?? '0.0',
                                maxLines: 1,
                                style: getRegularStyle(color: AppColors.white),
                              ),
                              5.w.horizontalSpace,
                              MySvgWidget(
                                path: AppIcons.rate,
                                width: 16.w,
                                height: 16.h,
                              ),
                            ],
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
            driver?.vehicleType ?? '',
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
