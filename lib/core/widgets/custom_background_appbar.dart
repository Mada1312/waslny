import 'package:waslny/core/exports.dart';

class CustomLoginAppbar extends StatelessWidget {
  const CustomLoginAppbar(
      {super.key,
      this.title,
      required this.imagePath,
      this.description,
      this.isWithBack = false});
  final String? title;
  final String imagePath;
  final String? description;
  final bool isWithBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: getHeightSize(context) / 4,
        width: double.infinity,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.sp),
                bottomRight: Radius.circular(20.sp),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: getHeightSize(context) / 4,
                width: double.infinity,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondPrimary.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.sp),
                  bottomRight: Radius.circular(20.sp),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWithBack) ...[
                    20.h.verticalSpace,
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Spacer()
                  ],
                  Flexible(
                    child: AutoSizeText(
                      title ?? '',
                      maxLines: 1,
                      style: getSemiBoldStyle(
                        color: AppColors.primary,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  AutoSizeText(
                    description ?? '',
                    maxLines: 1,
                    style: getRegularStyle(
                      color: AppColors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
