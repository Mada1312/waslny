import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/custom_background_appbar.dart';
import 'package:waslny/core/widgets/show_loading_indicator.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';
import 'widget/custom_pin_code.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen(
      {super.key, required this.isDriver, required this.isForgetPassword});
  final bool isDriver;
  final bool isForgetPassword;
  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
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
                        ? ImageAssets.driverBar
                        : ImageAssets.userCover,
                    description: widget.isForgetPassword
                        ? 'ener_verification_Code'.tr()
                        : 'ener_verification_Code2'.tr(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        80.h.verticalSpace,
                        CustomPinCodeWidget(
                            pinController: cubit.pinController,
                            onCompleted: (v) {
                              //!
                            }),

                        32.h.verticalSpace,
                        state is LoadingVerifyCodeState
                            ? const Center(
                                child: CustomLoadingIndicator(),
                              )
                            : CustomButton(
                                title: 'next'.tr(),
                                onPressed: () {
                                  if (widget.isForgetPassword) {
                                    Navigator.pushNamed(
                                        context, Routes.newPasswordScreen,
                                        arguments: widget.isDriver);
                                  } else {
                                    cubit.register(context, widget.isDriver);
                                  }
                                },
                              ),
                        // Center(child: ShowLoadingIndicator()),
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
