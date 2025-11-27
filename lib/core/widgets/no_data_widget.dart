import 'package:waslny/core/exports.dart';
import 'package:flutter/cupertino.dart';

class CustomNoDataWidget extends StatelessWidget {
  const CustomNoDataWidget({
    super.key,
    this.message,
    this.onTap,
  });
  final String? message;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            ImageAssets.noData,
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 10),
          Text(message ?? 'no_data'.tr(),
              textAlign: TextAlign.center, style: getBoldStyle()),
          const SizedBox(height: 10),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              child: Icon(
                CupertinoIcons.arrow_clockwise,
                color: AppColors.secondPrimary,
                size: 35,
              ),
            ),
        ],
      ),
    );
  }
}
