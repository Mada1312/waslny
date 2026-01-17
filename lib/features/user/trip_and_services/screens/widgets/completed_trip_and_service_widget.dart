import 'package:flutter_svg/svg.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/state.dart';

import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/cubit/state.dart';

import 'custom_from_to.dart';

class CompletedTripOrServiceItemWidget extends StatefulWidget {
  const CompletedTripOrServiceItemWidget({
    super.key,
    this.isDelivered = false,
    required this.isDriver,
    this.tripOrService,
  });

  final bool isDelivered;
  final bool isDriver;
  final TripAndServiceModel? tripOrService;

  @override
  State<CompletedTripOrServiceItemWidget> createState() =>
      _CompletedTripOrServiceItemWidgetState();
}

class _CompletedTripOrServiceItemWidgetState
    extends State<CompletedTripOrServiceItemWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserTripAndServicesCubit, UserTripAndServicesState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            showTripDetailsModal(
              context: context,
              tripDetails: widget.tripOrService,
              isDriver: widget.isDriver,
            );
          },
          child: Container(
            margin: EdgeInsets.all(2.w),
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: AppColors.second2Primary,

              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tripOrService?.from ?? '',
                          maxLines: 2,
                          style: getSemiBoldStyle(
                            fontSize: 14.sp,
                            fontweight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          widget.tripOrService?.serviceToName != null
                              ? widget.tripOrService?.serviceToName ?? ''
                              : widget.tripOrService?.to ?? '',
                          style: getRegularStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper function to show the bottom sheet
void showTripDetailsModal({
  required BuildContext context,
  required TripAndServiceModel? tripDetails,
  required bool isDriver,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: false,
    enableDrag: true,

    isScrollControlled: true, // Allows the sheet to take full height if needed
    backgroundColor: Colors.transparent, // Crucial for custom rounded corners
    builder: (context) {
      return TripDetailsBottomSheet(
        tripDetails: tripDetails,
        isDriver: isDriver,
      );
    },
  );
}

class TripDetailsBottomSheet extends StatelessWidget {
  final TripAndServiceModel? tripDetails;
  final bool isDriver;
  const TripDetailsBottomSheet({
    super.key,
    required this.tripDetails,
    required this.isDriver,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        var cubit = context.read<ProfileCubit>();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white, // Background color of the bottom sheet
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r), // Adjust radius as needed
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(25.h),
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: AppColors
                  .second2Primary, // Background color of the bottom sheet
              borderRadius: BorderRadius.all(
                Radius.circular(10.r), // Adjust radius as needed
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Make column take minimum space
              children: [
                // Drag handle (optional, but good for UX)
                Container(
                  width: 60.w, // Width of the drag handle
                  height: 5.h, // Height of the drag handle
                  margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                ),

                // Date and Time Row
                Row(
                  children: [
                    if (tripDetails?.type == 'Schedule' ||
                        tripDetails?.type == 'مجدولة')
                      Expanded(
                        child: Row(
                          children: [
                            MySvgWidget(
                              path: AppIcons.date,
                              height: 24.h,
                              // imageColor: AppColors.secondPrimary,
                            ),
                            10.w.horizontalSpace,
                            Flexible(
                              child: AutoSizeText(
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(tripDetails?.day ?? DateTime.now()),

                                maxLines: 1,
                                style: getRegularStyle(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (tripDetails?.type == 'Schedule' ||
                        tripDetails?.type == 'مجدولة')
                      Expanded(
                        child: Row(
                          children: [
                            MySvgWidget(
                              path: AppIcons.dateTime,
                              height: 24.h,
                              // imageColor: AppColors.secondPrimary,
                            ),
                            10.w.horizontalSpace,
                            Flexible(
                              child: AutoSizeText(
                                tripDetails?.time ?? '',

                                maxLines: 1,
                                style: getRegularStyle(),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),

                // From-To Section
                CustomFromToWidget(
                  from: tripDetails?.from ?? '',
                  to: tripDetails?.to ?? '',
                  fromLat: tripDetails?.fromLat,
                  fromLng: tripDetails?.fromLong,
                  serviceTo: tripDetails?.serviceToName,
                  toLat: tripDetails?.toLat,
                  toLng: tripDetails?.toLong,
                  isDriverAccepted: tripDetails?.isDriverAccept == 1,
                  isDriverArrived: tripDetails?.isDriverArrived == 1,
                ),

                // if (!(isDriver == true))
                SizedBox(height: 12.h),

                //!
                if (tripDetails?.distance != "")
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MySvgWidget(
                        path: AppIcons.fromMapIcon,
                        width: 35.sp,
                        height: 35.sp,
                        // imageColor: AppColors.dark2Grey,
                      ),
                      10.w.horizontalSpace,
                      Flexible(
                        child: Text(
                          "${(tripDetails?.distance != null && tripDetails!.distance!.isNotEmpty) ? tripDetails!.distance : '--'} ${'km'.tr()}",
                          style: getMediumStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),

                if (!(isDriver == true)) SizedBox(height: 12.h),
                if (!(isDriver == true))
                  // Action Buttons
                  Row(
                    children: [
                      10.h.horizontalSpace,
                      Expanded(
                        child: CustomButton(
                          title: 'make_trip'.tr(),
                          radius: 10.r,
                          onPressed: () {
                            customTripAndServiceCloneDialog(
                              controller: cubit.selectedDateTimeController,
                              isSchedule: false,

                              context,
                              btnOkText: 'confirm'.tr(),

                              title: 'sure_to_make_trip'.tr(),
                              onPressedOk: () {
                                cubit.cloneTrip(
                                  isSchedule: false,
                                  tripDetails?.id?.toString() ?? '',
                                  context: context,
                                );
                              },
                            );
                          },
                          textColor: AppColors.primary,
                          padding: EdgeInsets.all(5),
                          btnColor: AppColors.secondPrimary,
                        ),
                      ),
                      5.h.horizontalSpace,
                      Expanded(
                        child: CustomButton(
                          title: 'make_schedule_trip'.tr(),
                          radius: 10.r,
                          textColor: AppColors.primary,
                          onPressed: () {
                            customTripAndServiceCloneDialog(
                              controller: cubit.selectedDateTimeController,
                              isSchedule: true,
                              onTap: () {
                                cubit.selectDateTime(context);
                              },
                              context,
                              btnOkText: 'confirm'.tr(),

                              title: 'sure_to_make_schedule_trip'.tr(),
                              onPressedOk: () {
                                cubit.cloneTrip(
                                  isSchedule: true,
                                  tripDetails?.id?.toString() ?? '',
                                  context: context,
                                );
                              },
                            );
                          },
                          padding: EdgeInsets.all(5),
                          btnColor: AppColors.secondPrimary,
                        ),
                      ),
                      5.h.horizontalSpace,

                      InkWell(
                        onTap: () {
                          if (tripDetails?.isFav == true) {
                            warningDialog(
                              context,
                              btnOkText: 'delete'.tr(),

                              title: 'remove_from_fav'.tr(),
                              onPressedOk: () {
                                cubit.actionFav(
                                  isCompleteScreen: true,
                                  tripDetails?.id?.toString() ?? '',
                                  context: context,
                                  model: tripDetails,
                                );
                              },
                            );
                          } else {
                            cubit.actionFav(
                              isCompleteScreen: true,
                              model: tripDetails,
                              tripDetails?.id?.toString() ?? '',
                              context: context,
                            );
                          }

                          //! remove form fav
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.secondPrimary,

                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: tripDetails?.isFav == true
                                ? AppColors.primary
                                : AppColors.white,
                          ),
                        ),
                      ),
                      10.h.horizontalSpace,
                    ],
                  ),
                SizedBox(height: 12.h), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets for internal components ---

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.w, color: Colors.grey[700]),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the dotted line
class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  _DottedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startY = 0.0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0.0, startY),
        Offset(0.0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
