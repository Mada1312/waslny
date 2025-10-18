import 'dart:io';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';
import 'package:waslny/features/general/auth/cubit/state.dart';
import 'package:dotted_border/dotted_border.dart';

class UpdateUserProfile extends StatefulWidget {
  const UpdateUserProfile({super.key});

  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  @override
  void initState() {
    context.read<LoginCubit>().pickedProfileImage = null;
    context.read<LoginCubit>().pickedUserCardProfileImage = null;
    context.read<LoginCubit>().onTapToEdit(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        var cubit = context.read<LoginCubit>();
        return SafeArea(
          top: false,
          child: Scaffold(
            body: state is GetAuthDataLoading
                ? Center(child: CustomLoadingIndicator())
                : Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
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
                                    ImageAssets.userCover,
                                    fit: BoxFit.cover,
                                    height: getHeightSize(context) / 4,
                                    width: double.infinity,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.secondPrimary.withOpacity(
                                      0.8,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20.sp),
                                      bottomRight: Radius.circular(20.sp),
                                    ),
                                  ),
                                ),
                                PositionedDirectional(
                                  start: 16.w,
                                  top: 20.h,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 20.h,
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        10.w.horizontalSpace,
                                        AutoSizeText(
                                          'edit_account'.tr(),
                                          maxLines: 1,
                                          style: getRegularStyle(
                                            color: AppColors.white,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -50.h,
                                  child: Stack(
                                    alignment: Alignment.topLeft,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 60.r,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 50.r,
                                            backgroundImage:
                                                cubit.pickedProfileImage != null
                                                ? FileImage(
                                                    cubit.pickedProfileImage!,
                                                  )
                                                : cubit.authData?.data?.image !=
                                                      null
                                                ? NetworkImage(
                                                    cubit
                                                        .authData!
                                                        .data!
                                                        .image!,
                                                  )
                                                : const AssetImage(
                                                    ImageAssets.userIcon,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          await cubit.pickImageFromGallery();
                                          setState(() {});
                                        },
                                        child: CircleAvatar(
                                          radius: 20.r,
                                          backgroundColor: AppColors.primary,
                                          child: Icon(
                                            Icons.camera_alt_outlined,
                                            color: AppColors.white,
                                            size: 20.sp,
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
                      60.h.verticalSpace,
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 30.h.verticalSpace,
                                CustomTextField(
                                  title: 'name'.tr(),
                                  controller: cubit.updateNameController,
                                  hintText: 'name'.tr(),
                                  isRequired: true,
                                ),
                                10.h.verticalSpace,
                                CustomTextField(
                                  title: 'address'.tr(),
                                  controller: cubit.updateAddressController,
                                  hintText: 'address'.tr(),
                                  isRequired: true,
                                ),
                                10.h.verticalSpace,
                                CustomTextField(
                                  title: 'phone_number'.tr(),
                                  controller: cubit.updatePhoneNumberController,
                                  hintText: 'phone_number'.tr(),
                                  enabled: false,
                                  isRequired: true,
                                ),

                                //!
                                20.h.verticalSpace,
                                CustomButton(
                                  title: 'confirm'.tr(),
                                  onPressed: () {
                                    cubit.updateUserProfile(context);
                                  },
                                ),
                              ],
                            ),
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
