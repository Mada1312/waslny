import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/change_password/cubit/change_password_cubit.dart';
import 'package:waslny/features/general/change_password/cubit/change_password_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is SuccessChangePasswordState) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('change_password').tr(),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 16.h),
                  CustomTextField(
                    isPassword: true,
                    controller: _oldPasswordController,
                    hintText: 'current_password'.tr(),
                    validator: (value) => value == null || value.isEmpty
                        ? 'current_password'.tr()
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    isPassword: true,
                    controller: _newPasswordController,
                    hintText: 'new_password_required'.tr(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'new_password_required'.tr();
                      } else if (value.length < 6) {
                        return 'pass_validation'.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    isPassword: true,
                    controller: _confirmPasswordController,
                    hintText: 'confirm_password'.tr(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'confirm_password'.tr();
                      } else if (value != _newPasswordController.text) {
                        return 'not_identical_password'.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: CustomButton(
                      isDisabled: state is LoadingChangePasswordState,
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            _confirmPasswordController.text ==
                                _newPasswordController.text) {
                          context.read<ChangePasswordCubit>().updatePassword(
                            oldPassword: _oldPasswordController.text,
                            newPassword: _newPasswordController.text,
                            confirmPassword: _confirmPasswordController.text,
                          );
                        }
                      },
                      padding: EdgeInsets.all(0),
                      title: 'change_password'.tr(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
