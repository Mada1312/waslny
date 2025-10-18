import 'package:waslny/core/exports.dart';

class LocationInputWidget extends StatelessWidget {
  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const LocationInputWidget({
    super.key,
    required this.fromController,
    required this.toController,
    required this.onFromTap,
    required this.onToTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppColors.second2Primary,
      ),
      padding: EdgeInsets.all(8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and dashed line column
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MySvgWidget(path: AppIcons.from, height: 20.h, width: 20.h),
                SizedBox(height: 8),
                ...List.generate(
                  10,
                  (index) => Container(
                    width: 2.w,
                    height: 5,
                    color: AppColors.secondPrimary,
                    // margin: EdgeInsets.symmetric(vertical: 1),
                  ),
                ),
                SizedBox(height: 8),
                MySvgWidget(path: AppIcons.to, height: 20.h, width: 20.h),
              ],
            ),
            SizedBox(width: 10.w),

            // Input fields column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: fromController,
                    hintText: 'from'.tr(),
                    onTap: onFromTap,
                  ),
                  Divider(
                    height: 3,
                    color: AppColors.second4Primary,
                    endIndent: 10.w,
                  ),
                  _buildTextField(
                    controller: toController,
                    hintText: 'to'.tr(),
                    onTap: onToTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
      onTap: onTap,
      maxLines: 1,
      keyboardType: TextInputType.text,
      style: getRegularStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabled: true,
        hintText: hintText,
        hintStyle: getRegularStyle(fontSize: 14.sp, color: AppColors.grey),
        suffixIcon: InkWell(
          onTap: onTap,
          child: Icon(
            Icons.add_circle_rounded,
            size: 20.h,
            color: AppColors.secondPrimary,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'select_location'.tr();
        }
        return null;
      },
    );
  }
}
