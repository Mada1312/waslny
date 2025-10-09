import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_background_appbar.dart';
import 'package:waslny/features/general/auth/screens/widget/enum_gender.dart';
import 'package:waslny/features/general/profile/screens/privacy_screen.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.isDriver});
  final bool isDriver;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        var cubit = context.read<LoginCubit>();
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                CustomLoginAppbar(
                  isWithBack: true,
                  title: 'welcome_msg'.tr(),
                  imagePath: widget.isDriver
                      ? ImageAssets.driverLogin
                      : ImageAssets.userCover,
                  description: 'welcome_desc'.tr(),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Form(
                    key: key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        30.h.verticalSpace,
                        CustomTextField(
                          title: 'name'.tr(),
                          keyboardType: TextInputType.name,
                          controller: cubit.nameController,
                          hintText: 'enter_your_name'.tr(),
                          validationMessage: 'enter_your_name'.tr(),
                        ),
                        CustomPhoneFormField(
                          title: 'phone_number'.tr(),
                          isRequired: true,
                          controller: cubit.phoneNumberController,
                          onChanged: (p0) {
                            setState(() {
                              cubit.fullPhoneNumber = p0.completeNumber
                                  .replaceAll('+', '');
                            });
                            log('Phone completeNumber ${p0.completeNumber}');
                            log(
                              'Phone fullPhoneNumber ${cubit.fullPhoneNumber}',
                            );
                            log('Phone countryCode ${p0.countryCode}');
                            log('Phone number ${p0.number}');
                          },
                        ),
                        10.h.verticalSpace,
                        Row(
                          children: [
                            Expanded(
                              child: CustomDropdownButtonFormField<Gender>(
                                value: cubit.gender,
                                title: 'type'.tr(),
                                onChanged: (value) {
                                  setState(() {
                                    cubit.gender = value;
                                  });
                                },
                                items: Gender.values,
                                itemBuilder: (item) => item.displayValue,
                              ),
                            ),
                            10.w.horizontalSpace,
                            Expanded(
                              child: CustomDropdownButtonFormField<Gender>(
                                value: cubit.vehicleType,
                                title: 'vehicle_type'.tr(),

                                onChanged: (value) {
                                  setState(() {
                                    cubit.vehicleType = value;
                                  });
                                },
                                items: Gender.values,
                                itemBuilder: (item) => item.displayValue,
                              ),
                            ),
                          ],
                        ),
                        10.h.verticalSpace,
                        CustomTextField(
                          title: 'password'.tr(),
                          isPassword: true,
                          isRequired: true,
                          controller: cubit.passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          hintText: 'enter_password'.tr(),
                          validationMessage: 'enter_password'.tr(),
                        ),
                        CustomTextField(
                          isRequired: true,
                          validationMessage: 'enter_password'.tr(),
                          title: 'confirm_password'.tr(),
                          keyboardType: TextInputType.visiblePassword,
                          isPassword: true,
                          hintText: 'enter_password'.tr(),
                          controller: cubit.confirmPasswordController,
                        ),
                        10.h.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  cubit.onChangeStatus();
                                  setState(() {});
                                },
                                child: Container(
                                  width: 18.w,
                                  height: 18.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: cubit.acceptTermsAndConditions
                                        ? AppColors.secondPrimary
                                        : AppColors.transparent,
                                    border: Border.all(
                                      color: cubit.acceptTermsAndConditions
                                          ? AppColors.secondPrimary
                                          : const Color(0xff222222),
                                      width: 1.5.w,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: cubit.acceptTermsAndConditions
                                        ? AppColors.white
                                        : const Color(0xff222222),
                                    size: 12.w,
                                  ),
                                ),
                              ),
                              10.horizontalSpace,
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PrivacyAndTermsScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'accept_terms'.tr(),
                                  style: TextStyle(
                                    color: cubit.acceptTermsAndConditions
                                        ? AppColors.secondPrimary
                                        : const Color(0xff6D6D6D),
                                    fontSize: 13.sp,
                                    fontFamily: AppStrings.fontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        32.h.verticalSpace,
                        CustomButton(
                          title: 'sign_up'.tr(),
                          isDisabled: !cubit.acceptTermsAndConditions,
                          onPressed: () {
                            if (key.currentState!.validate() &&
                                cubit.acceptTermsAndConditions == true) {
                              if (cubit.passwordController.text ==
                                  cubit.confirmPasswordController.text) {
                                cubit.valudateData(context, widget.isDriver);
                              } else {
                                errorGetBar('not_identical_password'.tr());
                              }
                            }
                          },
                        ),

                        80.h.verticalSpace,
                        Padding(
                          padding: EdgeInsets.only(top: 5.0.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  //!
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    Routes.loginRoute,
                                    (route) => false,
                                    arguments: widget.isDriver,
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'have_account'.tr(),
                                        style: getRegularStyle(fontSize: 16.sp),
                                      ),
                                      TextSpan(
                                        text: ' ${'login'.tr()}',
                                        style: getMediumStyle(
                                          fontSize: 16.sp,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Center(child: ShowLoadingIndicator()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
