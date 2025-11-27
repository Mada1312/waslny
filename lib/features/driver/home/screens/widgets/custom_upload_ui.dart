import 'dart:io';

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/cubit/cubit.dart';
import 'package:waslny/features/driver/home/cubit/state.dart';

class PersonalPhotoStep extends StatelessWidget {
  const PersonalPhotoStep({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        return Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: RichText(
                text: TextSpan(
                  text: "${'personal_photo'.tr()} ",
                  style: getSemiBoldStyle(fontSize: 18.sp),
                  children: [
                    // TextSpan(
                    //   text: "id_card_faces".tr(),
                    //   style: getSemiBoldStyle(fontSize: 12.sp),
                    // ),
                  ],
                ),
              ),
            ),
            20.h.verticalSpace,
            CustomUploadImage(
              isSquare: true,
              imageFile: cubit.personalPhotoImage,
              // imageUrl: cubit.vehicleInfoFrontImageUrl,
              onTap: () => cubit.showCameraOrImagePicker(
                context,
                DriverDataImages.personalPhoto,
              ),
            ),
          ],
        );
      },
    );
  }
}

class IdCardStep extends StatelessWidget {
  const IdCardStep({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        return Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: RichText(
                text: TextSpan(
                  text: "${'id_card_photo'.tr()} ",
                  style: getSemiBoldStyle(fontSize: 18.sp),
                  children: [
                    TextSpan(
                      text: "id_card_faces".tr(),
                      style: getSemiBoldStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
            20.h.verticalSpace,
            CustomUploadImage(
              imageFile: cubit.idCardFrontImage,
              // imageUrl: cubit.vehicleInfoFrontImageUrl,
              onTap: () => cubit.showCameraOrImagePicker(
                context,
                DriverDataImages.idCardFront,
              ),
            ),
            20.h.verticalSpace,
            CustomUploadImage(
              imageFile: cubit.idCardBackImage,
              // imageUrl: cubit.vehicleInfoBackImageUrl,
              onTap: () => cubit.showCameraOrImagePicker(
                context,
                DriverDataImages.idCardBack,
              ),
            ),
          ],
        );
      },
    );
  }
}

class DriverLicenseStep extends StatelessWidget {
  const DriverLicenseStep({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        return Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: RichText(
                text: TextSpan(
                  text: "${'driver_license_photo'.tr()} ",
                  style: getSemiBoldStyle(fontSize: 18.sp),
                  children: [
                    TextSpan(
                      text: "driver_license_face".tr(),
                      style: getSemiBoldStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
            20.h.verticalSpace,
            CustomUploadImage(
              imageFile: cubit.driverLicenseImage,
              // imageUrl: cubit.vehicleInfoFrontImageUrl,
              onTap: () => cubit.showCameraOrImagePicker(
                context,
                DriverDataImages.driverLicense,
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomVehicleInfo extends StatelessWidget {
  const CustomVehicleInfo({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        return Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: RichText(
                text: TextSpan(
                  text: "${'car_license_photo'.tr()} ",
                  style: getSemiBoldStyle(fontSize: 18.sp),
                  children: [
                    TextSpan(
                      text: "id_card_faces".tr(),
                      style: getSemiBoldStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
            20.h.verticalSpace,
            CustomUploadImage(
              imageFile: cubit.vehicleInfoFrontImage,
              // imageUrl: cubit.vehicleInfoFrontImageUrl,
              onTap: () => cubit.showCameraOrImagePicker(
                context,
                DriverDataImages.vehicleInfoFront,
              ),
            ),
            20.h.verticalSpace,
            CustomUploadImage(
              imageFile: cubit.vehicleInfoBackImage,
              // imageUrl: cubit.vehicleInfoBackImageUrl,
              onTap: () => cubit.showCameraOrImagePicker(
                context,
                DriverDataImages.vehicleInfoBack,
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomUploadImage extends StatelessWidget {
  const CustomUploadImage({
    super.key,
    this.imageUrl,
    this.onTap,
    this.imageFile,
    this.isSquare = false,
  });
  final String? imageUrl;
  final VoidCallback? onTap;
  final File? imageFile;
  final bool isSquare;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeightSize(context) * 0.2,
      width: isSquare ? getHeightSize(context) * 0.2 : double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.menuContainer,
      ),
      child: InkWell(
        onTap: onTap,
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(imageFile!, fit: BoxFit.cover),
              )
            : imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(imageUrl!, fit: BoxFit.cover),
              )
            : Center(
                child: MySvgWidget(
                  path: AppIcons.upload,
                  width: 30.sp,
                  height: 30.sp,
                ),
              ),
      ),
    );
  }
}
