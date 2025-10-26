import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/screens/widgets/custom_upload_ui.dart';
import 'package:waslny/features/main/screens/main_screen.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class DriverDataScreen extends StatefulWidget {
  const DriverDataScreen({super.key});
  @override
  State<DriverDataScreen> createState() => _DriverDataScreenState();
}

class _DriverDataScreenState extends State<DriverDataScreen> {
  @override
  void initState() {
    context.read<DriverHomeCubit>().changeSelectedStep(1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            bool shouldExit = await showExitDialog(context);
            if (shouldExit) {
              SystemNavigator.pop();
            }
            return shouldExit;
          },
          child: Scaffold(
            appBar: customAppBar(
              context,
              leading: cubit.selectedStep != 1
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.black,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          cubit.changeSelectedStep(cubit.selectedStep - 1),
                    )
                  : Container(),
              title: 'fill_data_to_start'.tr(),
            ),
            body: Column(
              children: [
                10.h.verticalSpace,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < DriverDataSteps.values.length; i++) ...[
                      CustomStepNumber(
                        step: i + 1,
                        isSelected: cubit.selectedStep == i + 1,
                      ),
                      if (i != DriverDataSteps.values.length)
                        20.w.horizontalSpace, // space between items
                    ],
                  ],
                ),
                30.h.verticalSpace,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: IndexedStack(
                      index: cubit.selectedStep - 1,
                      children: const [
                        CustomVehicleInfo(),
                        DriverLicenseStep(),
                        IdCardStep(),
                        PersonalPhotoStep(),
                      ],
                    ),
                  ),
                ),
                20.h.verticalSpace,
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    isDisabled: cubit.isNextButtonDisabled(
                      DriverDataSteps.values[cubit.selectedStep - 1],
                    ),
                    title: 'next'.tr(),
                    onPressed: () =>
                        cubit.selectedStep + 1 > DriverDataSteps.values.length
                        ? cubit.updateDeliveryProfile(context)
                        : cubit.changeSelectedStep(cubit.selectedStep + 1),
                  ),
                ),
                20.h.verticalSpace,
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomStepNumber extends StatelessWidget {
  const CustomStepNumber({
    super.key,
    required this.step,
    this.isSelected = false,
  });
  final int step;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: isSelected ? AppColors.primary : AppColors.secondPrimary,
      child: Text(
        step.toString(),
        style: getMediumStyle(
          fontSize: 24.sp,
          fontHeight: 1.5,
          color: isSelected ? AppColors.secondPrimary : AppColors.primary,
        ),
      ),
    );
  }
}
