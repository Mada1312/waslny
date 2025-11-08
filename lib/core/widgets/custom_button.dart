import 'package:waslny/core/exports.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final bool isDisabled;
  final Color? btnColor;
  final Color? textColor;
  final double? width;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? fontSize;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.title,
    this.isDisabled = false,
    this.radius,
    this.padding,
    this.btnColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        height: height ?? 50.h,
        width: width ?? double.infinity,
        alignment: Alignment.center,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 5.w),
        // padding: padding ?? EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.primary.withOpacity(0.3)
              : btnColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(radius ?? 10.sp),
        ),
        child: AutoSizeText(
          title,
          maxLines: 1,
          style: getBoldStyle(
            color: textColor ?? AppColors.secondPrimary,
            fontSize: fontSize ?? 16.sp,
          ),
        ),
      ),
    );
  }
}
