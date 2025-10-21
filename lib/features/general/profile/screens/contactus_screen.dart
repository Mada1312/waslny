import 'package:waslny/core/utils/call_method.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:waslny/extention.dart';

import '../../../../core/exports.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  var key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        var cubit = context.read<ProfileCubit>();
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'contact_us'.tr(),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12.0.w),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(44.0.h),
                        child: Image.asset(
                          ImageAssets.contactUs,
                          width: 200.w,
                          height: 200.h,
                        ),
                      ),

                      CustomTextField(
                        title: 'name'.tr(),
                        hintText: 'enter_your_name'.tr(),
                        controller: cubit.nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'enter_your_name'.tr();
                          } else {
                            return null;
                          }
                        },
                      ),
                      CustomTextField(
                        title: 'message'.tr(),
                        isMessage: true,
                        hintText: 'enter_mesage'.tr(),
                        controller: cubit.messageController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'enter_mesage'.tr();
                          } else {
                            return null;
                          }
                        },
                      ),
                      50.h.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: CustomButton(
                          width: context.w,
                          padding: EdgeInsets.all(8.h),
                          radius: 10.r,
                          title: 'confirm'.tr(),
                          onPressed: () {
                            if (key.currentState!.validate()) {
                              cubit.contactUs(context);
                            }
                          },
                        ),
                      ),
                      50.h.verticalSpace,
                      Center(
                        child: Text(
                          'contact_us_using'.tr(),
                          style: getMediumStyle(
                            color: AppColors.secondPrimary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (cubit.settings?.data?.facebookLink != null)
                            IconButton(
                              onPressed: () async {
                                openExternal(
                                  cubit.settings?.data?.facebookLink ??
                                      'https://octopusteam.net/',
                                );
                              },
                              icon: MySvgWidget(path: AppIcons.facebook),
                            ),
                          if (cubit.settings?.data?.instaLink != null)
                            10.w.horizontalSpace,
                          if (cubit.settings?.data?.instaLink != null)
                            IconButton(
                              onPressed: () async {
                                openExternal(
                                  cubit.settings?.data?.instaLink ??
                                      'https://octopusteam.net/',
                                );
                              },
                              icon: MySvgWidget(path: AppIcons.insta),
                            ),
                          if (cubit.settings?.data?.whatsappNumber != null)
                            10.w.horizontalSpace,
                          if (cubit.settings?.data?.whatsappNumber != null)
                            IconButton(
                              onPressed: () async {
                                openExternal(
                                  cubit.settings?.data?.whatsappNumber ??
                                      'https://octopusteam.net/',
                                );
                              },
                              icon: MySvgWidget(path: AppIcons.whatsapp),
                            ),
                        ],
                      ),
                      (kBottomNavigationBarHeight + 5).h.verticalSpace,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
