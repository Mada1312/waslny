import 'package:waslny/core/exports.dart';

import 'package:waslny/features/general/location/cubit/location_cubit.dart';

class CustomFromToWidget extends StatelessWidget {
  const CustomFromToWidget({
    super.key,
    this.from,
    this.to,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
  });
  final String? from;
  final String? to;
  final String? fromLat;
  final String? fromLng;
  final String? toLat;
  final String? toLng;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  MySvgWidget(
                    path: AppIcons.from,
                    height: 20.h,
                    width: 20.h,
                    // imageColor: AppColors.dark2Grey,
                  ),
                  5.h.verticalSpace,
                  Expanded(
                    child: Column(
                      children: List.generate(
                        5,
                        (index) => Expanded(
                          child: Container(
                            width: 2.w,
                            color: AppColors.secondPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              10.w.horizontalSpace,
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    if (fromLat != null && fromLng != null) {
                      context.read<LocationCubit>().openGoogleMapsRoute(
                        double.tryParse(fromLat!) ?? 0,
                        double.tryParse(fromLng!) ?? 0,
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("from".tr(), style: getMediumStyle(fontSize: 14.sp)),
                      // 10.h.verticalSpace,
                      Text(
                        from ?? " ",
                        maxLines: 3,
                        style: getRegularStyle(
                          fontSize: 13.sp,
                          color: AppColors.grey,
                        ),
                      ),
                      10.h.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MySvgWidget(
              path: AppIcons.to,
              width: 20.w,
              height: 30.h,
              // imageColor: AppColors.dark2Grey,
            ),
            10.w.horizontalSpace,
            Flexible(
              child: GestureDetector(
                onTap: () async {
                  if (toLat != null && toLng != null) {
                    context.read<LocationCubit>().openGoogleMapsRoute(
                      double.tryParse(toLat!) ?? 0,
                      double.tryParse(toLng!) ?? 0,
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("to".tr(), style: getMediumStyle(fontSize: 14.sp)),
                    // 10.h.verticalSpace,
                    Text(
                      to ?? " ",
                      style: getRegularStyle(
                        fontSize: 13.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    // 20.h.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
