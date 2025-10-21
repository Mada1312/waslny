import 'dart:developer';

import 'package:waslny/core/exports.dart';

import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

import '../../../driver_details/screens/driver_details.dart';
import 'call_message.dart';

class CustomDriverInfo extends StatefulWidget {
  const CustomDriverInfo({
    super.key,
    this.hint,
    this.driver,
    this.shipmentCode,
    this.roomToken,
    this.tripId,
    this.isFavWidget,
  });
  final String? hint;
  final String? shipmentCode;
  final String? tripId;
  final String? roomToken;
  final Driver? driver;
  final bool? isFavWidget;

  @override
  State<CustomDriverInfo> createState() => _CustomDriverInfoState();
}

class _CustomDriverInfoState extends State<CustomDriverInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDriverCardInfo(driver: widget.driver),

        10.w.horizontalSpace,
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,

                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: GestureDetector(
                  onTap: () {
                    //! cancel Trip and service
                    log('Cancel Trip');
                  },
                  child: Center(
                    child: Text(
                      'cancel_trip'.tr(),
                      style: getMediumStyle(color: AppColors.secondPrimary),
                    ),
                  ),
                ),
              ),
            ),
            20.h.horizontalSpace,
            CustomCallAndMessageWidget(
              driverId:
                  widget.driver?.id?.toString() ??
                  widget.driver?.id?.toString(),
              name: widget.driver?.name ?? '',
              tripId: widget.tripId,
              roomToken: widget.roomToken,
              shipmentCode: widget.shipmentCode,
              phoneNumber: widget.driver?.phone.toString(),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomDriverCardInfo extends StatelessWidget {
  const CustomDriverCardInfo({super.key, this.driver});
  final Driver? driver;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverDetailsScreenById(
                driverId: driver?.id.toString() ?? '',
              ),
            ),
          );
        },
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 30.h),
              padding: EdgeInsets.all(5.h),
              decoration: BoxDecoration(
                color: AppColors.second5Primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  60.w.horizontalSpace,
                  Flexible(
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            driver?.name ?? '',
                            maxLines: 1,
                            style: getSemiBoldStyle(
                              fontSize: 16.sp,
                              color: AppColors.secondPrimary,
                            ),
                          ),

                          Text(
                            driver?.vehiclePlateNumber ?? '',
                            maxLines: 1,
                            style: getRegularStyle(
                              fontSize: 12.sp,
                              color: AppColors.secondPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CustomNetworkImage(
                image: driver?.image ?? "",
                isUser: true,
                borderRadius: 100,
                height: 60.h,
                width: 60.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
