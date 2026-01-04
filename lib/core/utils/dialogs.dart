import 'package:waslny/core/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waslny/core/utils/app_globals.dart';

/*============================================================================*/
/*                         TOP SNACKBAR HELPER                               */
/*============================================================================*/
void _showTopSnackBar({
  required String message,
  required Color backgroundColor,
  Duration duration = const Duration(seconds: 3),
  IconData? icon,
}) {
  final messenger = rootMessengerKey.currentState;
  if (messenger == null) return;

  // اقفل أي snackbar مفتوحة
  messenger.hideCurrentSnackBar();

  // جيب top padding من safe area
  final topPadding =
      WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      duration: duration,
      dismissDirection: DismissDirection.up,
      showCloseIcon: true,
      closeIconColor: Colors.white,

      // ✅ تخليها فوق
      margin: EdgeInsets.only(top: topPadding + 12, left: 12, right: 12),

      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

/*============================================================================*/
/*                              SUCCESS GET BAR                              */
/*============================================================================*/
void successGetBar(String? message) {
  final msg = message?.trim().isNotEmpty == true
      ? message!.trim()
      : 'success'.tr();

  _showTopSnackBar(
    message: msg,
    backgroundColor: AppColors.secondPrimary,
    icon: CupertinoIcons.checkmark_alt_circle_fill,
  );
}

/*============================================================================*/
/*                               ERROR GET BAR                               */
/*============================================================================*/
void errorGetBar(String? message) {
  final msg = message?.trim().isNotEmpty == true
      ? message!.trim()
      : 'error'.tr();

  _showTopSnackBar(
    message: msg,
    backgroundColor: AppColors.error,
    icon: CupertinoIcons.exclamationmark_triangle_fill,
  );
}

/*============================================================================*/
/*                             MESSAGE GET BAR                               */
/*============================================================================*/
void messageGetBar(String? message) {
  final msg = message?.trim().isNotEmpty == true
      ? message!.trim()
      : 'done'.tr();

  // ✅ استبدلت AppColors.info بـ AppColors.secondPrimary
  _showTopSnackBar(
    message: msg,
    backgroundColor: AppColors.secondPrimary,
    icon: CupertinoIcons.info_circle_fill,
  );
}

/*============================================================================*/
/*                            WARNING DIALOG                                 */
/*============================================================================*/
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title ?? 'warning'.tr(),
                      textAlign: TextAlign.center,
                      style: getRegularStyle(fontSize: 16.sp),
                    ),
                    if (desc != null) const SizedBox(height: 12),
                    if (desc != null)
                      Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: getMediumStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onPressedOk != null) onPressedOk();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondPrimary,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              btnOkText ?? 'confirm'.tr(),
                              style: getRegularStyle(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondPrimary,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'cancel'.tr(),
                              style: getRegularStyle(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
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

/*============================================================================*/
/*                           COMPLETE DIALOG                                 */
/*============================================================================*/
Future<void> completeDialog(
  BuildContext context, {
  void Function()? onPressedOk,
  String? title,
  String? btnOkText,
  String? desc,
}) async {
  await showGeneralDialog(
    context: context,
    barrierLabel: "CompleteDialog",
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Align(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.secondPrimary,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title ?? 'success'.tr(),
                        textAlign: TextAlign.center,
                        style: getSemiBoldStyle(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                      if (desc != null) const SizedBox(height: 10),
                      if (desc != null)
                        Text(
                          desc,
                          textAlign: TextAlign.center,
                          style: getRegularStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onPressedOk != null) onPressedOk();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          btnOkText ?? 'done'.tr(),
                          style: getRegularStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
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
      );
    },
  );
}

/*============================================================================*/
/*                  CUSTOM TRIP AND SERVICE CLONE DIALOG                     */
/*============================================================================*/
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        ImageAssets.dialogLogo,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    Text(
                      title ?? 'warning'.tr(),
                      textAlign: TextAlign.center,
                      style: getRegularStyle(fontSize: 16.sp),
                    ),
                    const SizedBox(height: 16),
                    if (isSchedule == true)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CustomTextField(
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
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (onPressedOk != null) onPressedOk();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondPrimary,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              btnOkText ?? 'confirm'.tr(),
                              style: getRegularStyle(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondPrimary,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'cancel'.tr(),
                              style: getRegularStyle(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
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
