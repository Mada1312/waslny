import 'package:waslny/core/exports.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? title;
  final String? validationMessage;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? initialValue;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? borderRadius;
  final bool enabled;
  final bool isMessage;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isReadOnly;
  final Color? backgroundColor;
  //FocusNode myFocusNode = FocusNode();
  const CustomTextField({
    super.key,
    this.hintText,
    this.validationMessage,
    this.title,
    this.isRequired = true,
    this.prefixIcon,
    this.validator,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.isMessage = false,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onTap,
    this.isPassword = false,
    this.onSubmitted,
    this.borderRadius,
    this.enabled = true,
    this.inputFormatters,
    this.isReadOnly = false,
    this.backgroundColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode myFocusNode = FocusNode();
  bool showPassword = false;
  @override
  void initState() {
    super.initState();

    myFocusNode.addListener(() {
      setState(() {
        // color = Colors.black;
      });
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: widget.isMessage ? 200.h : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.title ?? '',
                        style: getMediumStyle(color: AppColors.secondPrimary),
                      ),
                      TextSpan(
                        text: widget.isRequired ? ' *' : '',
                        style: getMediumStyle(color: AppColors.red),
                      ),
                    ],
                  ),
                ),
              ),
            MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: TextFormField(
                enabled: widget.enabled,
                readOnly: widget.isReadOnly,
                controller: widget.controller,
                // expands: false,
                onTap: widget.onTap,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                focusNode: myFocusNode,
                style: getRegularStyle(color: AppColors.secondPrimary),
                onChanged: widget.onChanged,
                validator: widget.isRequired
                    ? widget.validator ??
                          (value) {
                            if (value == null || value.isEmpty) {
                              return widget.validationMessage ?? '';
                            }
                            return null;
                          }
                    : null,
                keyboardType: widget.keyboardType ?? TextInputType.text,
                maxLines: widget.isMessage ? 5 : 1,
                minLines: widget.isMessage ? 5 : 1,
                onFieldSubmitted: widget.onSubmitted,
                inputFormatters: widget.inputFormatters,
                initialValue: widget.initialValue,
                obscureText: widget.isPassword ? !showPassword : false,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      widget.backgroundColor ??
                      AppColors.secondPrimary.withAlpha(25),
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon,
                  prefixIconColor: myFocusNode.hasFocus
                      ? AppColors.primary
                      : AppColors.darkGrey,
                  suffixIconColor: myFocusNode.hasFocus
                      ? AppColors.primary
                      : AppColors.darkGrey,
                  suffixIcon: widget.isPassword
                      ? showPassword
                            ? IconButton(
                                icon: Icon(
                                  widget.isPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.secondPrimary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                              )
                            : IconButton(
                                icon: Icon(
                                  !widget.isPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.secondPrimary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                              )
                      : widget.suffixIcon,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12.h,
                  ),
                  hintStyle: getRegularStyle(fontSize: 14.sp),
                  errorStyle: getRegularStyle(color: AppColors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.lightGrey,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius ?? 10.r),
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gray, width: 1.5),
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius ?? 10.r),
                    ),
                  ),
                  // focused border style
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.secondPrimary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius ?? 10.r),
                    ),
                  ),

                  // error border style
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.red, width: 1.5),
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius ?? 10.r),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.red, width: 1.5),
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius ?? 10.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPhoneFormField extends StatelessWidget {
  const CustomPhoneFormField({
    super.key,
    this.onCountryChanged,
    this.onChanged,
    this.controller,
    this.title,
    this.enabled = true,
    this.isRequired = false,
    this.initialValue,
  });

  final void Function(Country)? onCountryChanged;
  final void Function(PhoneNumber)? onChanged;
  final TextEditingController? controller;
  final bool? enabled;
  final bool isRequired;
  final String? initialValue;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Directionality(
          textDirection:
              EasyLocalization.of(context)?.locale.languageCode == 'ar'
              ? TextDirection.ltr
              : TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 3.0.w),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: IntlPhoneField(
                controller: controller,
                showCountryFlag: false,
                style: getMediumStyle(color: AppColors.secondPrimary),

                // invalidNumberMessage: "dasdas",
                dropdownTextStyle: getBoldStyle(fontSize: 13.sp),

                // validator: (value) {
                //   if (value == null ) {
                //     return 'enter your phone';
                //   }
                //   return null;
                // },
                keyboardType: TextInputType.number,
                disableLengthCheck: false,

                validator: (p0) {
                  if (p0 == null) {
                    return 'enter_your_number'.tr();
                  }
                  return null;
                },
                invalidNumberMessage: 'enter_valid_number'.tr(),
                showDropdownIcon: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: enabled!
                      ? AppColors.secondPrimary.withAlpha(25)
                      : AppColors.secondPrimary.withAlpha(25),
                  counterText: '',
                  hintText: 'enter_your_number'.tr(),

                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12.h,
                  ),
                  hintStyle: getRegularStyle(fontSize: 14.sp),
                  errorStyle: getRegularStyle(color: AppColors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.secondPrimary.withAlpha(25),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gray, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),
                  // focused border style
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.secondPrimary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),

                  // error border style
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.red, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.red, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),
                ),
                onCountryChanged: onCountryChanged,
                initialValue: initialValue ?? '+20',
                // initialCountryCode: 'EG', // Saudi Arabia country code
                onChanged: onChanged,
                textAlign:
                    EasyLocalization.of(context)?.locale.languageCode == 'ar'
                    ? TextAlign.start
                    : TextAlign.start,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
