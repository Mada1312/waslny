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
                                  nationalNumber.startsWith('0')) {
                                cubit.phoneNumberForgetController.text =
                                    nationalNumber.substring(1);

                                nationalNumber = nationalNumber.substring(1);
                                errorGetBar('enter_valid_egyptian_number'.tr());
                              }

                              String countryCode = phone.countryCode.replaceAll(
                                '+',
                                '',
                              );

                              cubit.fullPhoneNumber =
                                  "$countryCode$nationalNumber";
                            });
                           
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
