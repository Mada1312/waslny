// import 'package:awesome_dialog/awesome_dialog.dart';
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
  Get.showSnackbar(
    GetSnackBar(
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
    ),
  );
}

/*----------------------------------------------------------------------------*/
/*------------------------------  Message Get Bar  ---------------------------*/
/*----------------------------------------------------------------------------*/
messageGetBar(String message) {
  Get.showSnackbar(
    GetSnackBar(
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
    ),
  );
}

// warningDialog(
//   BuildContext context, {
//   void Function()? onPressedOk,
//   String? title,
//   String? btnOkText,
//   String? desc,
// }) async {
//   await AwesomeDialog(
//     context: context,
//     customHeader: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Image.asset(ImageAssets.dialogLogo, width: 80, height: 80),
//     ),
//     animType: AnimType.TOPSLIDE,
//     showCloseIcon: false, // لأنك هتعمل زرار Cancel بنفسك
//     body: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           title ?? "warning".tr(),
//           textAlign: TextAlign.center,
//           style: getRegularStyle(fontSize: 16.sp),
//         ),
//         const SizedBox(height: 10),
//         if (desc != null)
//           Text(
//             desc,
//             textAlign: TextAlign.center,
//             style: getMediumStyle(fontSize: 14.sp),
//           ),
//         const SizedBox(height: 20),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (onPressedOk != null) onPressedOk();
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.secondPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     btnOkText ?? "confirm".tr(),
//                     style: getRegularStyle(color: AppColors.primary),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.secondPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     "cancel".tr(),
//                     style: getRegularStyle(color: AppColors.primary),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   ).show();
// }

// customTripAndServiceCloneDialog(
//   BuildContext context, {
//   void Function()? onPressedOk,
//   String? title,
//   bool? isSchedule,
//   TextEditingController? controller,
//   dynamic Function()? onTap,
//   String? btnOkText,
// }) async {
//   await AwesomeDialog(
//     context: context,
//     customHeader: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Image.asset(ImageAssets.dialogLogo, width: 80, height: 80),
//     ),
//     animType: AnimType.TOPSLIDE,
//     showCloseIcon: false, // لأنك هتعمل زرار Cancel بنفسك
//     body: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           title ?? "warning".tr(),
//           textAlign: TextAlign.center,
//           style: getRegularStyle(fontSize: 16.sp),
//         ),
//         const SizedBox(height: 10),
//         if (isSchedule == true)
//           CustomTextField(
//             borderRadius: 20.r,
//             isRequired: false,
//             textAlign: TextAlign.center,
//             isReadOnly: true,
//             controller: controller,
//             keyboardType: TextInputType.datetime,
//             hintText: 'YYYY-MM-DD',
//             onTap: onTap,
//             validationMessage: 'date_is_required'.tr(),
//           ),
//         const SizedBox(height: 20),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (onPressedOk != null) onPressedOk();
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.secondPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     btnOkText ?? "confirm".tr(),
//                     style: getRegularStyle(color: AppColors.primary),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.secondPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     "cancel".tr(),
//                     style: getRegularStyle(color: AppColors.primary),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   ).show();
// }
Future<void> warningDialog(
  BuildContext context, {
  void Function()? onPressedOk,
  String? title,
  String? btnOkText,
  String? desc,
}) async {
  await showGeneralDialog(
    context: context,
    barrierLabel: "WarningDialog",
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        ImageAssets.dialogLogo,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    Text(
                      title ?? "warning".tr(),
                      textAlign: TextAlign.center,
                      style: getRegularStyle(fontSize: 16.sp),
                    ),
                    const SizedBox(height: 10),
                    if (desc != null)
                      Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: getMediumStyle(fontSize: 14.sp),
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (onPressedOk != null) onPressedOk();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                btnOkText ?? "confirm".tr(),
                                style: getRegularStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "cancel".tr(),
                                style: getRegularStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

Future<void> customTripAndServiceCloneDialog(
  BuildContext context, {
  void Function()? onPressedOk,
  String? title,
  bool? isSchedule,
  TextEditingController? controller,
  dynamic Function()? onTap,
  String? btnOkText,
}) async {
  await showGeneralDialog(
    context: context,
    barrierLabel: "TripCloneDialog",
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        ImageAssets.dialogLogo,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    Text(
                      title ?? "warning".tr(),
                      textAlign: TextAlign.center,
                      style: getRegularStyle(fontSize: 16.sp),
                    ),
                    const SizedBox(height: 10),
                    if (isSchedule == true)
                      CustomTextField(
                        borderRadius: 20.r,
                        isRequired: false,
                        textAlign: TextAlign.center,
                        isReadOnly: true,
                        controller: controller,
                        keyboardType: TextInputType.datetime,
                        hintText: 'YYYY-MM-DD',
                        onTap: onTap,
                        validationMessage: 'date_is_required'.tr(),
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (onPressedOk != null) onPressedOk();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                btnOkText ?? "confirm".tr(),
                                style: getRegularStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "cancel".tr(),
                                style: getRegularStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
