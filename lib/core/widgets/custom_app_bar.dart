import 'package:waslny/core/exports.dart';

PreferredSizeWidget customAppBar(BuildContext context,
    {String title = '',
    VoidCallback? onBack,
    List<Widget>? actions,
    double? height,
    Widget? leading}) {
  return AppBar(
    backgroundColor: AppColors.white,
    elevation: 0,
    toolbarHeight: height,
    leading: leading ??
        IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            // Icons.arrow_back_ios_sharp,
            color: AppColors.black,
          ),
          padding: EdgeInsets.zero,
          onPressed: onBack ?? () => Navigator.pop(context),
        ),
    title: Text(
      title,
      style: getMediumStyle(
        fontSize: 18.sp,
      ),
    ),
    actions: actions,
  );
}
