import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';
import '../../../../core/preferences/preferences.dart';
import '../../../../core/utils/restart_app_class.dart';
import '../../auth/cubit/state.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import 'favourit_trips.dart';
import 'privacy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.isDriver});
  final bool isDriver;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        var cubit = context.read<ProfileCubit>();

        return SafeArea(
          top: false,
          child: Scaffold(
            body: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: getHeightSize(context) / 4,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.sp),
                              bottomRight: Radius.circular(20.sp),
                            ),
                            child: Image.asset(
                              isDriver
                                  ? ImageAssets.driverLogin
                                  : ImageAssets.userCover,
                              fit: BoxFit.cover,
                              height: getHeightSize(context) / 4,
                              width: double.infinity,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondPrimary.withOpacity(0.8),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20.sp),
                                bottomRight: Radius.circular(20.sp),
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            start: 16.w,
                            top: 20.h,
                            child: isDriver
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Image.asset(
                                      ImageAssets.driverBack,
                                      height: 80.sp,
                                      width: 80.sp,
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 20.h,
                                    ),
                                    child: AutoSizeText(
                                      'my_account'.tr(),
                                      maxLines: 1,
                                      style: getSemiBoldStyle(
                                        color: AppColors.white,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: -50.h,
                            child: Center(
                              child: BlocBuilder<LoginCubit, LoginState>(
                                builder: (context, state) {
                                  var loginCubit = context.read<LoginCubit>();
                                  return Container(
                                    padding: EdgeInsets.all(5.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondPrimary,
                                      borderRadius: BorderRadius.circular(1000),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(
                                            0,
                                            3,
                                          ), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: CustomNetworkImage(
                                      image:
                                          loginCubit.authData?.data?.image ??
                                          "",
                                      isUser: true,
                                      height: 100.h,
                                      width: 100.h,
                                      borderRadius: 1000,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getHorizontalPadding(context),
                    ),
                    child: Column(
                      children: [
                        60.h.verticalSpace,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BlocBuilder<LoginCubit, LoginState>(
                              builder: (context, state) {
                                var loginCubit = context.read<LoginCubit>();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      loginCubit.authData?.data?.name ?? '',
                                      textAlign: TextAlign.center,
                                      style: getMediumStyle(fontSize: 18.sp),
                                    ),
                                    5.h.verticalSpace,
                                    Text(
                                      loginCubit.authData?.data?.phone
                                              .toString() ??
                                          '',
                                      style: getRegularStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                    5.h.verticalSpace,
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                //! Done
                                // if (!isDriver)
                                //   CustomProfileRow(
                                //     onTap: () {
                                //       Navigator.pushNamed(
                                //         context,
                                //         Routes.userTripsAndServicesRoute,
                                //       );

                                //       //!
                                //     },
                                //     title: 'trip_history',
                                //     path: AppIcons.shipmentLog,
                                //   ),
                                if (!isDriver)
                                  CustomProfileRow(
                                    title: 'favorites',
                                    path: AppIcons.myFavorites,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserFavTripsAndServices(),
                                        ),
                                      );
                                    },
                                  ),

                                if (!isDriver)
                                  CustomProfileRow(
                                    title: 'edit_account',
                                    path: AppIcons.editProfile,
                                    onTap: () {
                                      if (isDriver) {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.editDeliveryProfileRoute,
                                        );
                                      } else {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.editUserProfileRoute,
                                        );
                                      }
                                    },
                                  ),
                                CustomProfileRow(
                                  title: 'change_langauge'.tr(),
                                  path: AppIcons.lang,
                                  islang: true,
                                  onTap: () {
                                    if (EasyLocalization.of(
                                          context,
                                        )!.locale.languageCode ==
                                        'ar') {
                                      EasyLocalization.of(
                                        context,
                                      )!.setLocale(const Locale('en', ''));
                                      Preferences.instance.savedLang('en');
                                      Preferences.instance.getSavedLang();
                                      // HotRestartController.performHotRestart(context);
                                    } else {
                                      EasyLocalization.of(
                                        context,
                                      )!.setLocale(const Locale('ar', ''));
                                      Preferences.instance.savedLang('ar');
                                      Preferences.instance.getSavedLang();
                                    }
                                    HotRestartController.performHotRestart(
                                      context,
                                    );
                                  },
                                ),

                                //! Done
                                CustomProfileRow(
                                  title: 'contact_us',
                                  path: AppIcons.contactUs,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.contactUsScreen,
                                    );
                                  },
                                ),
                                if (!isDriver)
                                  CustomProfileRow(
                                    title: 'change_password',
                                    path: AppIcons.changePass,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.changePasswordScreen,
                                      );
                                    },
                                  ),

                                //TODO
                                CustomProfileRow(
                                  title: 'terms_and_conditions',
                                  path: AppIcons.terms,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrivacyAndTermsScreen(),
                                      ),
                                    );
                                  },
                                ),

                                //! Done
                                CustomProfileRow(
                                  title: 'share_app',
                                  path: AppIcons.share,
                                  onTap: () async {
                                    await cubit.shareApp();
                                  },
                                ),

                                //! Done
                                CustomProfileRow(
                                  title: 'rate_app',
                                  path: AppIcons.rateApp,
                                  onTap: () async {
                                    await cubit.rateApp();
                                  },
                                ),

                                //! Done
                                CustomProfileRow(
                                  title: 'delete_account',
                                  path: AppIcons.deleteAccount,
                                  onTap: () {
                                    warningDialog(
                                      context,
                                      title: 'confirm_delete_account'.tr(),
                                      btnOkText: 'delete'.tr(),
                                      onPressedOk: () {
                                        cubit.deleteAccount(context);
                                      },
                                    );
                                  },
                                ),
                                //! Done
                                CustomProfileRow(
                                  title: 'logout',
                                  path: AppIcons.logout,
                                  onTap: () {
                                    warningDialog(
                                      context,
                                      title: 'confirm_logout'.tr(),
                                      onPressedOk: () {
                                        cubit.logout(context);
                                      },
                                    );
                                  },
                                ),
                                (kBottomNavigationBarHeight + 5)
                                    .h
                                    .verticalSpace,
                              ],
                            ),
                          ),
                        ),
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

class CustomProfileRow extends StatelessWidget {
  const CustomProfileRow({
    super.key,
    required this.title,
    required this.path,
    this.onTap,
    this.islang = false,
  });
  final String title;
  final String path;
  final void Function()? onTap;
  final bool? islang;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.menuContainer,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: [
              MySvgWidget(
                path: path,
                // imageColor: AppColors.secondPrimary,
                height: 24.w,
                width: 24.w,
              ),
              10.w.horizontalSpace,
              Expanded(
                child: Text(
                  title.tr(),
                  style: getRegularStyle(fontSize: 16.sp),
                ),
              ),
              islang == true
                  ? Text(
                      EasyLocalization.of(context)!.locale.languageCode == 'ar'
                          ? "English"
                          : "العربية",
                      style: getRegularStyle(fontSize: 14.sp),
                    )
                  : Icon(
                      Icons.arrow_forward_ios_sharp,
                      size: 22.w,
                      color: AppColors.secondPrimary,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
