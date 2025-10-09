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
