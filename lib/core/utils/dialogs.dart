import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:waslny/core/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';

/*----------------------------------------------------------------------------*/
/*------------------------------  Error Get Bar  -----------------------------*/
/*----------------------------------------------------------------------------*/
errorGetBar(String message) {
  Get.showSnackbar(
    GetSnackBar(
      messageText: Text(
        message,
        style: Get.textTheme.titleSmall!.copyWith(
          color: Colors.white,
          height: 1.3,
        ),
      ),
      icon: const Icon(Icons.error_outline_outlined, color: Colors.white),
      backgroundColor: AppColors.error,
      barBlur: 5.0,
      borderRadius: 12.0,
      duration: const Duration(seconds: 2),
      isDismissible: true,
      margin: const EdgeInsets.all(12.0),
      snackPosition: SnackPosition.BOTTOM,
    ),
  );
}

/*----------------------------------------------------------------------------*/
/*------------------------------  Success Get Bar  ---------------------------*/
/*----------------------------------------------------------------------------*/

successGetBar(String? message) {
  Get.showSnackbar(GetSnackBar(
    messageText: Text(
      message ?? 'success'.tr(),
      style: Get.textTheme.bodyMedium!.copyWith(
        color: Colors.white,
        height: 1.5,
      ),
    ),
    icon: const Icon(CupertinoIcons.checkmark_seal, color: Colors.white),
    backgroundColor: AppColors.secondPrimary,
    barBlur: 5.0,
    borderRadius: 12.0,
    duration: const Duration(milliseconds: 2500),
    isDismissible: true,
    margin: const EdgeInsets.all(8.0),
    snackPosition: SnackPosition.TOP,
  ));
}

/*----------------------------------------------------------------------------*/
/*------------------------------  Message Get Bar  ---------------------------*/
/*----------------------------------------------------------------------------*/
messageGetBar(String message) {
  Get.showSnackbar(GetSnackBar(
    messageText: Text(
      message,
      style: Get.textTheme.labelMedium!.copyWith(
        color: Colors.white,
        height: 1.5,
      ),
    ),
    icon: const Icon(CupertinoIcons.arrow_left_circle, color: Colors.white),
    backgroundColor: Get.theme.primaryColor,
    barBlur: 5.0,
    borderRadius: 12.0,
    duration: const Duration(seconds: 3),
    isDismissible: true,
    margin: const EdgeInsets.all(8.0),
    snackPosition: SnackPosition.TOP,
  ));
}

deleteAccountDialog(BuildContext context, {void Function()? onPressed}) async {
  await AwesomeDialog(
    context: context,
    customHeader: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        ImageAssets.appIcon,
        color: AppColors.primary,
      ),
    ),
    animType: AnimType.topSlide,
    showCloseIcon: true,
    padding: EdgeInsets.all(10.w),
    title: "delete_account_desc".tr(),
    titleTextStyle: getRegularStyle(fontSize: 16.sp),
    btnOkText: "delete".tr(),
    btnOkOnPress: onPressed,
    btnCancelOnPress: () {},
    btnCancelText: "cancel".tr(),
  ).show();
}

warningDialog(BuildContext context,
    {void Function()? onPressedOk,
    String? title,
    String? btnOkText,
    String? desc}) async {
  await AwesomeDialog(
    context: context,
    customHeader: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        ImageAssets.appIcon,
        color: AppColors.primary,
        width: 80,
        height: 80,
      ),
    ),
    animType: AnimType.topSlide,
    reverseBtnOrder: true,
    showCloseIcon: true,
    padding: EdgeInsets.all(10.w),
    title: title ?? "warning".tr(),
    titleTextStyle: getRegularStyle(fontSize: 16.sp),
    desc: desc,
    descTextStyle: getMediumStyle(fontSize: 14.sp),
    btnOkText: btnOkText ?? "confirm".tr(),
    btnCancelIcon: Icons.close,
    btnOkColor: AppColors.primary,
    btnOkIcon: Icons.check,
    btnOkOnPress: onPressedOk,
    btnCancelOnPress: () {},
    btnCancelText: "cancel".tr(),
  ).show();
}
