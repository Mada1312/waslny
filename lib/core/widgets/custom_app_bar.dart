import 'package:waslny/core/exports.dart';

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
        IconButton(
          icon: Icon(
            isDriverBackIcon
                ? Icons.arrow_back_ios_sharp
                : Icons.arrow_back_rounded,
            // Icons.arrow_back_ios_sharp,
            color: AppColors.black,
          ),
          padding: EdgeInsets.zero,
          onPressed: onBack ?? () => Navigator.pop(context),
        ),
    title: titleWidget ?? Text(title, style: getMediumStyle(fontSize: 18.sp)),
    actions: actions,
  );
}

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
//     toolbarHeight: isDriverBackIcon ? 100.sp : height,
//     leading:
//         leading ??
//         (isDriverBackIcon
//             ? MySvgWidget(
//                 path: AppIcons.backButton,
//                 height: 80.sp,
//                 width: 80.sp,
//               )
//             : IconButton(
//                 icon: Icon(
//                   Icons.arrow_back_rounded,
//                   // Icons.arrow_back_ios_sharp,
//                   color: AppColors.black,
//                 ),
//                 padding: EdgeInsets.zero,
//                 onPressed: onBack ?? () => Navigator.pop(context),
//               )),
//     title: titleWidget ?? Text(title, style: getMediumStyle(fontSize: 18.sp)),
//     actions: actions,
//   );
// }
