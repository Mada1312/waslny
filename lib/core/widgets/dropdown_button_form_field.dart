import '../exports.dart';

typedef DropdownItemBuilder<T> = String Function(T item);

class CustomDropdownButtonFormField<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final DropdownItemBuilder<T> itemBuilder;
  final InputDecoration? decoration;
  final String? title;
  final bool isRequired;
  final String? validationMessage;
  final String? hintText;
  final Color? fillColor;
  final double? borderRadius;
  const CustomDropdownButtonFormField({
    super.key,
    required this.items,
    this.value,
    this.fillColor,
    this.onChanged,
    this.validator,
    this.decoration,
    required this.itemBuilder,
    this.title,
    this.isRequired = false,
    this.validationMessage,
    this.hintText,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title ?? '',
                    style: getMediumStyle(color: AppColors.secondPrimary),
                  ),
                  TextSpan(
                    text: isRequired ? ' *' : '',
                    style: getMediumStyle(color: AppColors.red),
                  ),
                ],
              ),
            ),
          ),
        DropdownButtonFormField<T>(
          icon: Container(),
          value: value,
          validator: isRequired
              ? validator ??
                    (value) {
                      if (value == null || value == '') {
                        return validationMessage ?? '';
                      }
                      return null;
                    }
              : null,
          hint: Text(
            hintText ?? "choose".tr(),
            style: getRegularStyle(
              fontSize: 14.sp,
              color: AppColors.secondPrimary,
            ),
          ),
          elevation: 0,
          decoration: InputDecoration(
            hintText: hintText ?? "choose",
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            hintStyle: getRegularStyle(
              fontSize: 10.sp,
              color: AppColors.secondPrimary,
            ),
            filled: true,
            fillColor: fillColor ?? AppColors.second2Primary,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: fillColor ?? AppColors.second2Primary,
                width: 0,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius ?? 10.r),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: fillColor ?? AppColors.second2Primary,
                width: 0.w,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius ?? 10.r),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: fillColor ?? AppColors.second2Primary,
                width: 0.w,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius ?? 10.r),
              ),
            ),
            alignLabelWithHint: true,
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.secondPrimary,
              ),
            ),
          ),
          style: getMediumStyle(color: AppColors.black, fontSize: 14.sp),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: AutoSizeText(
                itemBuilder(item),
                maxLines: 1,
                // Use the itemBuilder to display the item
                style: getMediumStyle(color: AppColors.black, fontSize: 14.sp),
              ),
            );
          }).toList(),
          dropdownColor: fillColor ?? AppColors.second2Primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
