import 'package:waslny/core/widgets/show_loading_indicator.dart';
import 'package:get/get.dart' as gets;
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import '../exports.dart';

class AppWidget {
  static createProgressDialog(BuildContext context, {String? msg}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return CustomLoadingIndicator();
          // return AlertDialog(
          //     backgroundColor: AppColors.transparent,
          //     content: CustomLoadingIndicator());
        });
  }

//!---------------- Loading Dialog With Logo we will use it  -------------

  loadingDialogWithLogo({required bool isLoading, required Widget child}) {
    return OverlayLoaderWithAppIcon(
        isLoading: isLoading,
        circularProgressColor: AppColors.primary,
        borderRadius: 15.0,
        appIcon: Image.asset(ImageAssets.loaderIcon),
        child: Container(child: child));
  }

//!---------------- LoadingDialogWithText  ----------------

  loadingDialogWithText() {
    gets.Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetAnimationCurve: Curves.bounceInOut,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringTranslateExtension('loading').tr(),
                style: gets.Get.textTheme.labelMedium!.copyWith(
                  color: gets.Get.theme.primaryColor,
                ),
              ),
              const SizedBox(width: 5),
              CircularProgressIndicator(
                  color: gets.Get.theme.colorScheme.secondary),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      transitionCurve: Curves.easeInOutBack,
    );
  }

//!-----------------------------------------------------
}
