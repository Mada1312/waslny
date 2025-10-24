import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_background_appbar.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.isDriver});
  final bool isDriver;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  title: 'welcome'.tr(),
                  imagePath: widget.isDriver
                      ? ImageAssets.driverLogin
                      : ImageAssets.userCover,
                  description: 'fill_data_to_enter'.tr(),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Form(
                    key: key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        50.h.verticalSpace,
                        CustomPhoneFormField(
                          title: 'phone_number'.tr(),
                          isRequired: true,
                          controller: cubit.phoneNumberController,
                          onChanged: (phone) {
                            setState(() {
                              String nationalNumber = phone.number;

                              if (phone.countryISOCode == 'EG' &&
                                  nationalNumber.startsWith('0') &&
                                  nationalNumber.length == 11) {
                                // If it's an 11-digit EG number, remove the leading '0'
                                // "01012345678" -> "1012345678"
                                nationalNumber = nationalNumber.substring(1);
                              }

                              // Get the country code without the '+' (e.g., "+20" -> "20")
                              String countryCode = phone.countryCode.replaceAll(
                                '+',
                                '',
                              );

                              // Combine them to get the full number your Cubit/API expects
                              // "20" + "1012345678" = "201012345678"
                              cubit.fullPhoneNumber =
                                  "$countryCode$nationalNumber";
                            });
                            // setState(() {
                            //   cubit.fullPhoneNumber =
                            //       p0.completeNumber.replaceAll('+', '');
                            // });
                            // log('Phone completeNumber ${p0.completeNumber}');
                            // log('Phone fullPhoneNumber ${cubit.fullPhoneNumber}');
                            // log('Phone countryCode ${p0.countryCode}');
                            // log('Phone number ${p0.number}');
                          },
                        ),
                        // 80.h.verticalSpace,
                        // CustomTextField(
                        //   title: 'phone_number'.tr(),
                        //   keyboardType: TextInputType.phone,
                        //   controller: cubit.phoneNumberController,
                        //   hintText: 'enter_your_number'.tr(),
                        //   validationMessage: 'enter_your_number'.tr(),
                        // ),
                        10.h.verticalSpace,
                        CustomTextField(
                          title: 'password'.tr(),
                          isPassword: true,
                          isRequired: true,
                          controller: cubit.passwordController,
                          hintText: 'enter_password'.tr(),
                          validationMessage: 'enter_password'.tr(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5.0.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  //!
                                  Navigator.pushNamed(
                                    context,
                                    Routes.forgetPasswordScreen,
                                    arguments: widget.isDriver,
                                  );
                                },
                                child: Text(
                                  'forget_password'.tr(),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        32.h.verticalSpace,

                        CustomButton(
                          title: 'login'.tr(),
                          onPressed: () {
                            if (key.currentState!.validate()) {
                              cubit.login(context, widget.isDriver);
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
                                  Navigator.pushNamed(
                                    context,
                                    Routes.signUpRoute,
                                    arguments: widget.isDriver,
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'dont_have_account'.tr(),
                                        style: getRegularStyle(fontSize: 16.sp),
                                      ),
                                      TextSpan(
                                        text: ' ${'sign_up'.tr()}',
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

// class LoginScreen extends StatefulWidget {
  // const LoginScreen({super.key, required this.isDriver});
  // final bool isDriver;
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CustomTextField(
//               title: 'رقم الهاتف',
//               hintText: 'Enter your email',
//             ),
            // CustomDropdownButtonFormField(
            //   items: [
            //     'Item 1',
            //     'Item 2',
            //     'Item 3',
            //   ],
            //   itemBuilder: (item) {
            //     return item;
            //   },
            //   onChanged: (value) {
            //     // Handle the selected value
            //   },
            // ),
//             20.h.verticalSpace,
//             CustomButton(
//                 title: 'Login',
//                 onPressed: () {
//                   Navigator.pushNamed(context, Routes.mainRoute,
//                       arguments: widget.isDriver);
//                 }),
//           ],
//         ),
//       ),
//     );
//   }
// }
