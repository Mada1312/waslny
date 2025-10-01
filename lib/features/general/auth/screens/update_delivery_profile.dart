import 'dart:io';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/user/add_new_shipment/cubit/state.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';
import 'package:waslny/features/general/auth/cubit/state.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../../core/widgets/multi_dropdown_button_form_field.dart';
import '../../../user/add_new_shipment/cubit/cubit.dart';
import '../../../user/add_new_shipment/data/models/countries_and_types_model.dart';

class UpdateDeliveryProfile extends StatefulWidget {
  const UpdateDeliveryProfile({super.key});

  @override
  State<UpdateDeliveryProfile> createState() => _UpdateDeliveryProfileState();
}

class _UpdateDeliveryProfileState extends State<UpdateDeliveryProfile> {
  @override
  void initState() {
    context.read<LoginCubit>().pickedProfileImage = null;
    context.read<LoginCubit>().pickedUserCardProfileImage = null;
    context.read<LoginCubit>().onTapToEdit(context, isDeriver: true);
    if (context.read<AddNewShipmentCubit>().allCountries == null) {
      context.read<AddNewShipmentCubit>().getCountriesAndTruckType(false);
    }
    if (context.read<AddNewShipmentCubit>().allTruckType == null) {
      context.read<AddNewShipmentCubit>().getCountriesAndTruckType(true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewShipmentCubit, AddNewShipmentState>(
      builder: (context, state) {
        var countryAndTypeCubit = context.read<AddNewShipmentCubit>();
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
                                          ImageAssets.driverBar,
                                          fit: BoxFit.cover,
                                          height: getHeightSize(context) / 4,
                                          width: double.infinity,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.secondPrimary
                                              .withOpacity(0.8),
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
                                              horizontal: 16.w, vertical: 20.h),
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
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ]),
                                              child: CircleAvatar(
                                                radius: 60.r,
                                                backgroundColor: Colors.white,
                                                child: CircleAvatar(
                                                    radius: 50.r,
                                                    backgroundImage: cubit
                                                                .pickedProfileImage !=
                                                            null
                                                        ? FileImage(cubit
                                                            .pickedProfileImage!)
                                                        : cubit.authData?.data
                                                                    ?.image !=
                                                                null
                                                            ? NetworkImage(cubit
                                                                .authData!
                                                                .data!
                                                                .image!)
                                                            : const AssetImage(
                                                                ImageAssets
                                                                    .userIcon)),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                await cubit
                                                    .pickImageFromGallery();
                                                setState(() {});
                                              },
                                              child: CircleAvatar(
                                                radius: 20.r,
                                                backgroundColor:
                                                    AppColors.primary,
                                                child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  color: AppColors.white,
                                                  size: 20.sp,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
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
                                    //! Country
                                    countryAndTypeCubit
                                                .allCountries?.data?.length ==
                                            0
                                        ? Container()
                                        : MultiSelectDropdownWithChips<
                                            GetCountriesAndTruckTypeModelData>(
                                            title: 'to'.tr(),
                                            hintText: 'select_location'.tr(),
                                            selectedValues: countryAndTypeCubit
                                                .selectedCountriesAtEditProfile,
                                            validationMessage:
                                                'select_location'.tr(),
                                            isRequired: true,
                                            items: countryAndTypeCubit
                                                    .allCountries?.data ??
                                                [],
                                            itemBuilder: (item) {
                                              return item.name ?? '';
                                            },
                                            onChanged: (value) {
                                              countryAndTypeCubit
                                                      .selectedCountriesAtEditProfile =
                                                  value.toSet().toList();

                                              // Handle the selected value
                                            },
                                          ),
                                    5.h.verticalSpace,

                                    //! Type
                                    countryAndTypeCubit
                                                .allTruckType?.data?.length ==
                                            0
                                        ? Container()
                                        : CustomDropdownButtonFormField<
                                            GetCountriesAndTruckTypeModelData>(
                                            title: 'shipment_type'.tr(),
                                            value: countryAndTypeCubit
                                                .shipmentType,
                                            validationMessage:
                                                'shipment_type'.tr(),
                                            validator: (value) {
                                              if (value == null) {
                                                return 'shipment_type'.tr();
                                              }
                                              return null;
                                            },
                                            isRequired: true,
                                            items: countryAndTypeCubit
                                                    .allTruckType?.data ??
                                                [],
                                            itemBuilder: (item) {
                                              return item.name ?? '';
                                            },
                                            onChanged: (value) {
                                              countryAndTypeCubit.shipmentType =
                                                  value;
                                              // Handle the selected value
                                            },
                                          ),
                                    5.h.verticalSpace,
                                    10.h.verticalSpace,
                                    CustomTextField(
                                      title: 'phone_number'.tr(),
                                      controller:
                                          cubit.updatePhoneNumberController,
                                      hintText: 'phone_number'.tr(),
                                      enabled: false,
                                      isRequired: true,
                                    ),
                                    10.h.verticalSpace,
                                    if (cubit.updateNationalIdController.text
                                        .isNotEmpty)
                                      CustomTextField(
                                        title: 'national_id'.tr(),
                                        controller:
                                            cubit.updateNationalIdController,
                                        hintText: 'national_id'.tr(),
                                        enabled: false,
                                        isRequired: true,
                                      ),
                                    //!
                                    10.h.verticalSpace,

                                    Text('driver_card'.tr(),
                                        style: getMediumStyle()),
                                    10.h.verticalSpace,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await cubit
                                                  .pickUserCardImageFromGallery(
                                                      isDeliveryBackImage: true,
                                                      isBackImage: false);
                                              setState(() {});
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(5.0.sp),
                                              child: DottedBorder(
                                                color: Colors.black12,
                                                strokeWidth: 1,
                                                borderType: BorderType.RRect,
                                                radius: Radius.circular(8),
                                                dashPattern: [12, 3],
                                                child: SizedBox(
                                                  height: 150.h,
                                                  child: Stack(
                                                    children: [
                                                      // Display either the placeholder or the uploaded image

                                                      (cubit.authData?.data
                                                                      ?.frontDriverCard !=
                                                                  null &&
                                                              cubit.pickedDeliveryFrontImage ==
                                                                  null)
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.r),
                                                              child:
                                                                  Image.network(
                                                                cubit
                                                                        .authData
                                                                        ?.data
                                                                        ?.frontDriverCard ??
                                                                    '',
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                                height: 150.h,
                                                                errorBuilder:
                                                                    (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Center(
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .all(20
                                                                            .sp),
                                                                    child: Image
                                                                        .asset(
                                                                      ImageAssets
                                                                          .logo,
                                                                      // color: AppColors
                                                                      //     .primary,
                                                                      width:
                                                                          40.w,
                                                                      height:
                                                                          40.h,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : cubit.pickedDeliveryFrontImage ==
                                                                  null
                                                              ? Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .cloud_upload_outlined,
                                                                          size: 40
                                                                              .sp,
                                                                          color:
                                                                              AppColors.primary),
                                                                      SizedBox(
                                                                          height:
                                                                              10.h),
                                                                      Text(
                                                                        'upload_front'
                                                                            .tr(),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[600],
                                                                          fontSize:
                                                                              14.sp,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.r),
                                                                  child: Image
                                                                      .file(
                                                                    File(cubit
                                                                        .pickedDeliveryFrontImage!
                                                                        .path),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: double
                                                                        .infinity,
                                                                    height:
                                                                        150.h,
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Center(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.all(20.sp),
                                                                        child: Image
                                                                            .asset(
                                                                          ImageAssets
                                                                              .logo,
                                                                          // color:
                                                                          //     AppColors.primary,
                                                                          width:
                                                                              40.w,
                                                                          height:
                                                                              40.h,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                      // Show remove button only if an image is uploaded
                                                      if (cubit.pickedDeliveryFrontImage !=
                                                              null ||
                                                          cubit.authData?.data
                                                                  ?.frontDriverCard !=
                                                              null)
                                                        Positioned(
                                                          top: 10.h,
                                                          right: 10.w,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              cubit.pickedDeliveryFrontImage =
                                                                  null;
                                                              cubit
                                                                      .authData
                                                                      ?.data
                                                                      ?.frontDriverCard =
                                                                  null;
                                                              setState(() {});
                                                            },
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              radius: 15.r,
                                                              child: Icon(
                                                                Icons
                                                                    .close_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 18.sp,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        5.w.horizontalSpace,
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await cubit
                                                  .pickUserCardImageFromGallery(
                                                      isDeliveryBackImage: true,
                                                      isBackImage: true);
                                              setState(() {});
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(5.0.sp),
                                              child: DottedBorder(
                                                color: Colors.black12,
                                                strokeWidth: 1,
                                                borderType: BorderType.RRect,
                                                radius: Radius.circular(8),
                                                dashPattern: [12, 3],
                                                child: SizedBox(
                                                  height: 150.h,
                                                  child: Stack(
                                                    children: [
                                                      // Display either the placeholder or the uploaded image

                                                      (cubit.authData?.data
                                                                      ?.backDriverCard !=
                                                                  null &&
                                                              cubit.pickedDeliveryBackImage ==
                                                                  null)
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.r),
                                                              child:
                                                                  Image.network(
                                                                cubit
                                                                        .authData
                                                                        ?.data
                                                                        ?.backDriverCard ??
                                                                    '',
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                                height: 150.h,
                                                                errorBuilder:
                                                                    (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Center(
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .all(20
                                                                            .sp),
                                                                    child: Image
                                                                        .asset(
                                                                      ImageAssets
                                                                          .logo,
                                                                      // color: AppColors
                                                                      //     .primary,
                                                                      width:
                                                                          40.w,
                                                                      height:
                                                                          40.h,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : cubit.pickedDeliveryBackImage ==
                                                                  null
                                                              ? Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .cloud_upload_outlined,
                                                                          size: 40
                                                                              .sp,
                                                                          color:
                                                                              AppColors.primary),
                                                                      SizedBox(
                                                                          height:
                                                                              10.h),
                                                                      Text(
                                                                        'upload_back'
                                                                            .tr(),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[600],
                                                                          fontSize:
                                                                              14.sp,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.r),
                                                                  child: Image
                                                                      .file(
                                                                    File(cubit
                                                                        .pickedDeliveryBackImage!
                                                                        .path),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: double
                                                                        .infinity,
                                                                    height:
                                                                        150.h,
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Center(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.all(20.sp),
                                                                        child: Image
                                                                            .asset(
                                                                          ImageAssets
                                                                              .logo,
                                                                          // color:
                                                                          //     AppColors.primary,
                                                                          width:
                                                                              40.w,
                                                                          height:
                                                                              40.h,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                      // Show remove button only if an image is uploaded
                                                      if (cubit.pickedDeliveryBackImage !=
                                                              null ||
                                                          cubit.authData?.data
                                                                  ?.backDriverCard !=
                                                              null)
                                                        Positioned(
                                                          top: 10.h,
                                                          right: 10.w,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              cubit.pickedDeliveryBackImage =
                                                                  null;
                                                              cubit
                                                                      .authData
                                                                      ?.data
                                                                      ?.backDriverCard =
                                                                  null;
                                                              setState(() {});
                                                            },
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              radius: 15.r,
                                                              child: Icon(
                                                                Icons
                                                                    .close_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 18.sp,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    20.h.verticalSpace,
                                    CustomButton(
                                      title: 'confirm'.tr(),
                                      onPressed: () {
                                        cubit.updateDeliveryProfile(context);
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
      },
    );
  }
}
