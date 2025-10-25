import 'dart:developer';

import 'package:waslny/config/routes/app_routes.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_background_appbar.dart';
import 'package:waslny/core/widgets/show_loading_indicator.dart';
import 'package:easy_localization/easy_localization.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key, required this.isDriver});
  final bool isDriver;
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
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
                  imagePath: widget.isDriver
                      ? ImageAssets.driverLogin
                      : ImageAssets.userCover,
                  description: 'verify_code_msg'.tr(),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Form(
                    key: key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        80.h.verticalSpace,
                        CustomPhoneFormField(
                          title: 'phone_number'.tr(),
                          isRequired: true,
                          controller: cubit.phoneNumberForgetController,
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
                        32.h.verticalSpace,

                        CustomButton(
                          title: 'send'.tr(),
                          onPressed: () {
                            if (key.currentState!.validate()) {
                              cubit.forgetPasswordRequest(
                                context,
                                widget.isDriver,
                              );
                            }
                          },
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
