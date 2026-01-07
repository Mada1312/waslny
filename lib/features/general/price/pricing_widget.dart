import 'package:flutter/material.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'pricing_engine.dart';

class PricingDialog extends StatelessWidget {
  final DriverTripModel trip;
  final bool isFemaleDriver;
  final VoidCallback onConfirm;

  const PricingDialog({
    super.key,
    required this.trip,
    required this.isFemaleDriver,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ حساب السعر من الرحلة نفسها
    final int finalPrice = PricingEngine.calculateFareFromTrip(
      trip: trip,
      isFemaleDriver: isFemaleDriver,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة السعر
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "تكلفة الرحلة".tr(),
              style: getBoldStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // السعر
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  finalPrice.toString(),
                  style: getBoldStyle(color: Colors.red, fontSize: 42),
                ),
                const SizedBox(width: 6),
                Text(
                  "جنيهاَ".tr(),
                  style: getMediumStyle(color: Colors.red, fontSize: 18),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // زر التأكيد
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onConfirm,
                child: Text(
                  "confirm".tr(),
                  style: getMediumStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
