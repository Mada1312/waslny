import 'package:waslny/core/exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/utils/call_method.dart';
import '../../../../core/utils/get_size.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding_widget.dart';

class OnBoardinScreen extends StatefulWidget {
  const OnBoardinScreen({super.key});

  @override
  State<OnBoardinScreen> createState() => _OnBoardinScreenState();
}

class _OnBoardinScreenState extends State<OnBoardinScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnBoardingCubit, OnboardingState>(
      listener: (context, state) {},
      builder: (context, state) {
        OnBoardingCubit cubit = context.read<OnBoardingCubit>();
        return OrientationBuilder(
          builder: (context, orientation) {
            return SafeArea(
              top: false,
              child: Scaffold(
                body: SizedBox(
                  height: getHeightSize(context),
                  width: getWidthSize(context),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView(
                        controller: cubit.pageController,
                        onPageChanged: (int page) {
                          cubit.onPageChanged(page);
                        },
                        children: [
                          OnBoardingWidget(
                            page: 1,
                          ),
                          OnBoardingWidget(
                            page: 2,
                          ),
                          OnBoardingWidget(
                            page: 3,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: getHeightSize(context) * 0.2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: getHorizontalPadding(context),
                                vertical: getHeightSize(context) * 0.03,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  3,
                                  (index) => Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 3.w),
                                    width: 35.w,
                                    height: getHeightSize(context) * 0.006,
                                    decoration: BoxDecoration(
                                      color: index == cubit.currentPage
                                          ? AppColors.primary
                                          : AppColors.grey2,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: getHeightSize(context) * 0.03,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: getHorizontalPadding(context),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  cubit.currentPage == 2
                                      ? Container()
                                      : InkWell(
                                          onTap: () async {
                                            SharedPreferences pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            pref.setBool('onBoarding', true);

                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                Routes.chooseLoginRoute,
                                                (route) => false);
                                          },
                                          child: Text("skip".tr(),
                                              style: getRegularStyle(
                                                  color: AppColors.white))),
                                  InkWell(
                                    onTap: () async {
                                      if (cubit.currentPage == 2) {
                                        SharedPreferences pref =
                                            await SharedPreferences
                                                .getInstance();
                                        pref.setBool('onBoarding', true);
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            Routes.chooseLoginRoute,
                                            (route) => false);
                                      } else {
                                        cubit.pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30.w,
                                        vertical: 10.h,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.white,
                                        // size: 20.r,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
