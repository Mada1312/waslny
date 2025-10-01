import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/call_method.dart';
import 'package:waslny/features/general/on_boarding/cubit/onboarding_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingWidget extends StatelessWidget {
  const OnBoardingWidget({
    super.key,
    required this.page,
  });
  final int page;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnBoardingCubit, OnboardingState>(
        builder: (context, state) {
      OnBoardingCubit cubit = context.read<OnBoardingCubit>();
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            page == 1
                ? ImageAssets.introBackgroundImage1
                : page == 2
                    ? ImageAssets.introBackgroundImage2
                    : ImageAssets.introBackgroundImage3,
            fit: BoxFit.cover,
            height: getHeightSize(context),
            width: double.infinity,
          ),
          Container(
            color: AppColors.secondPrimary.withOpacity(0.8),
          ),
          Image.asset(
            ImageAssets.onBoardingOverlay,
            fit: BoxFit.cover,
            height: getHeightSize(context),
            width: double.infinity,
          ),
          Container(
            // color: AppColors.red,
            padding: EdgeInsets.symmetric(
              horizontal: getHorizontalPadding(context),
            ),
            // height: getHeightSize(context) * 0.13,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  page == 1
                      ? 'on_board_title1'.tr()
                      : page == 2
                          ? 'on_board_title2'.tr()
                          : page == 3
                              ? 'on_board_title3'.tr()
                              : "",
                  style:
                      getSemiBoldStyle(fontSize: 20.sp, color: AppColors.white),
                ),
                SizedBox(height: getHeightSize(context) * 0.01),
                AutoSizeText(
                  page == 1
                      ? 'on_board_desc1'.tr()
                      : page == 2
                          ? 'on_board_desc2'.tr()
                          : page == 3
                              ? 'on_board_desc3'.tr()
                              : "",
                  maxLines: 2,
                  style: getRegularStyle(
                    color: AppColors.white,
                  ),
                ),
                SizedBox(
                  height: getHeightSize(context) * 0.22,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
