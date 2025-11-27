import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_background_appbar.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, required this.isDriver});
  final bool isDriver;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
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
                  description: 'enter_password'.tr(),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Form(
                    key: key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        80.h.verticalSpace,
                        CustomTextField(
                          title: 'password'.tr(),
                          isPassword: true,
                          validationMessage: 'enter_password'.tr(),
                          isRequired: true,
                          controller: cubit.newPasswordController,
                          hintText: 'enter_password'.tr(),
                        ),
                        12.h.verticalSpace,
                        CustomTextField(
                          isRequired: true,
                          validationMessage: 'enter_password'.tr(),
                          title: 'confirm_password'.tr(),
                          isPassword: true,
                          hintText: 'enter_password'.tr(),
                          controller: cubit.confirmNewPasswordController,
                        ),

                        32.h.verticalSpace,

                        CustomButton(
                          title: 'send'.tr(),
                          onPressed: () {
                            if (cubit.newPasswordController.text ==
                                cubit.confirmNewPasswordController.text) {
                              if (key.currentState!.validate()) {
                                cubit.resetPassword(context, widget.isDriver);
                              }
                            } else {
                              errorGetBar('not_identical_password'.tr());
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
