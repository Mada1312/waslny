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
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onPressed,
      // borderRadius: BorderRadius.circular(30.sp),
      child: Container(
        width: width ?? double.infinity,
        alignment: Alignment.center,
        padding: padding ?? EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.primary.withOpacity(0.3)
              : btnColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(radius ?? 10.sp),
        ),
        child: AutoSizeText(
          title,
          style: getBoldStyle(
            color: textColor ?? AppColors.secondPrimary,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
