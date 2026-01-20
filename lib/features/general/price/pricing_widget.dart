import 'package:flutter/material.dart';
import 'package:waslny/core/exports.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  final double tripPrice;
  final double distanceKm;
  final bool isFemaleDriver;
  final VoidCallback onConfirm;
  final VoidCallback onWaiting;

  const PaymentConfirmationDialog({
    super.key,
    required this.tripPrice,
    required this.distanceKm,
    required this.isFemaleDriver,
    required this.onConfirm,
    required this.onWaiting,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة المال
            Container(
              width: 80.sp,
              height: 80.sp,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.monetization_on,
                size: 50.sp,
                color: Colors.green,
              ),
            ),

            20.h.verticalSpace,

            // العنوان
            Text(
              'تفاصيل الرحلة',
              style: getBoldStyle(
                fontSize: 20.sp,
                color: AppColors.secondPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            16.h.verticalSpace,

            // تفاصيل التسعيرة
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: AppColors.second2Primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'نوع الكابتن',
                    isFemaleDriver ? 'Female'.tr() : 'Male'.tr(),
                  ),
                  8.h.verticalSpace,
                  _buildDetailRow(
                    'المسافة',
                    '${distanceKm.toStringAsFixed(2)} كم',
                  ),
                  8.h.verticalSpace,
                  Divider(color: AppColors.grey.withOpacity(0.3)),
                  8.h.verticalSpace,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'المبلغ المستحق',
                        style: getBoldStyle(
                          fontSize: 16.sp,
                          color: AppColors.secondPrimary,
                        ),
                      ),
                      Text(
                        '${tripPrice.toStringAsFixed(0)} جنيه',
                        style: getBoldStyle(
                          fontSize: 24.sp,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            24.h.verticalSpace,

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: 'تأكيد',
                    height: 50.h,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: getRegularStyle(fontSize: 14.sp, color: AppColors.grey),
        ),
        Text(
          value,
          style: getSemiBoldStyle(
            fontSize: 14.sp,
            color: AppColors.secondPrimary,
          ),
        ),
      ],
    );
  }
}

// دالة عرض الـ Dialog
Future<void> showPaymentConfirmationDialog(
  BuildContext context, {
  required double tripPrice,
  required double distanceKm,
  required bool isFemaleDriver,
  required VoidCallback onPaymentConfirmed,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PaymentConfirmationDialog(
      tripPrice: tripPrice,
      distanceKm: distanceKm,
      isFemaleDriver: isFemaleDriver,
      onConfirm: () {
        Navigator.pop(context); // إغلاق الـ Dialog
        onPaymentConfirmed(); // callback
      },
      onWaiting: () {
        Navigator.pop(context);
      },
    ),
  );
}
