import 'package:waslny/features/user/add_new_trip/cubit/cubit.dart';

import '../../../../../core/exports.dart';

class LatestLocationsWidgets extends StatelessWidget {
  const LatestLocationsWidgets({
    super.key,
    this.showAll = false,
    required this.cubit,
  });

  final AddNewTripCubit cubit;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: ((cubit.latestLocation?.data?.length ?? 0) > 3 && !showAll)
          ? 3
          : cubit.latestLocation?.data?.length ?? 0,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var item = cubit.latestLocation?.data?[index];
        return GestureDetector(
          onTap: () {
            //! SET SELECTED LOCATION
            cubit.setSelectedLocationToFields(item!);
            if (showAll) {
              Navigator.pop(context);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: AppColors.second2Primary,
            ),
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: AppColors.second3Primary,
                  ),
                  padding: EdgeInsets.all(8),
                  child: MySvgWidget(path: AppIcons.dateTime),
                ),
                10.w.horizontalSpace,
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item?.from ?? '',
                        style: getSemiBoldStyle(fontSize: 14.sp),
                        maxLines: 1,
                      ),
                      Text(
                        item?.isService == 1
                            ? item?.serviceToName ?? ''
                            : item?.to ?? '',
                        style: getRegularStyle(fontSize: 12.sp),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
