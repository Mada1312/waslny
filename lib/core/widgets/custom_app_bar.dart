// import 'package:waslny/core/exports.dart';

// PreferredSizeWidget customAppBar(
//   BuildContext context, {
//   String title = '',
//   VoidCallback? onBack,
//   List<Widget>? actions,
//   double? height,
//   Widget? leading,
//   Widget? titleWidget,
//   bool isCenterTitle = false,
//   bool isDriverBackIcon = false,
// }) {
//   return AppBar(
//     backgroundColor: AppColors.white,
//     elevation: 0,
//     centerTitle: isCenterTitle,
//     toolbarHeight: height,
//     leading:
//         leading ??
//         IconButton(
//           icon: isDriverBackIcon
//               ? Image.asset(ImageAssets.driverBack, height: 80.sp, width: 80.sp)
//               : Icon(
//                   Icons.arrow_back_rounded,
//                   // Icons.arrow_back_ios_sharp,
//                   color: AppColors.black,
//                 ),
//           padding: EdgeInsets.zero,
//           onPressed: onBack ?? () => Navigator.pop(context),
//         ),
//     title: titleWidget ?? Text(title, style: getMediumStyle(fontSize: 18.sp)),
//     actions: actions,
//   );
// }

// // PreferredSizeWidget customAppBar(
// //   BuildContext context, {
// //   String title = '',
// //   VoidCallback? onBack,
// //   List<Widget>? actions,
// //   double? height,
// //   Widget? leading,
// //   Widget? titleWidget,
// //   bool isCenterTitle = false,
// //   bool isDriverBackIcon = false,
// // }) {
// //   return AppBar(
// //     backgroundColor: AppColors.white,
// //     elevation: 0,
// //     centerTitle: isCenterTitle,
// //     toolbarHeight: isDriverBackIcon ? 100.sp : height,
// //     leading:
// //         leading ??
// //         (isDriverBackIcon
// //             ? MySvgWidget(
// //                 path: AppIcons.backButton,
// //                 height: 80.sp,
// //                 width: 80.sp,
// //               )
// //             : IconButton(
// //                 icon: Icon(
// //                   Icons.arrow_back_rounded,
// //                   // Icons.arrow_back_ios_sharp,
// //                   color: AppColors.black,
// //                 ),
// //                 padding: EdgeInsets.zero,
// //                 onPressed: onBack ?? () => Navigator.pop(context),
// //               )),
// //     title: titleWidget ?? Text(title, style: getMediumStyle(fontSize: 18.sp)),
// //     actions: actions,
// //   );
// // }
import 'package:waslny/core/exports.dart';
import 'dart:math' as math;

import 'package:waslny/core/preferences/preferences.dart';

PreferredSizeWidget customAppBar(
  BuildContext context, {
  String title = '',
  VoidCallback? onBack,
  List<Widget>? actions,
  double? height,
  Widget? leading,
  Widget? titleWidget,
  bool isCenterTitle = false,
  bool isDriverBackIcon = false,
}) {
  return AppBar(
    backgroundColor: AppColors.white,
    elevation: 0,
    centerTitle: isCenterTitle,
    toolbarHeight: height,
    leading:
        leading ??
        (isDriverBackIcon
            ? FutureBuilder<String?>(
                future: Preferences.instance.getSavedLang(),
                builder: (context, snapshot) {
                  final lang = snapshot.data ?? 'ar';
                  final shouldRotate = lang == 'en';

                  return IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onBack ?? () => Navigator.pop(context),
                    icon: Transform.rotate(
                      angle: shouldRotate ? math.pi : 0, // 180 درجة
                      child: Image.asset(
                        ImageAssets.driverBack,
                        height: 80.sp,
                        width: 80.sp,
                      ),
                    ),
                  );
                },
              )
            : IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: AppColors.black),
                padding: EdgeInsets.zero,
                onPressed: onBack ?? () => Navigator.pop(context),
              )),
    title: titleWidget ?? Text(title, style: getMediumStyle(fontSize: 18.sp)),
    actions: actions,
  );
}
