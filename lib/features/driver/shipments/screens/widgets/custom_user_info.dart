import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/driver/shipments/cubit/cubit.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/shipments/screens/widgets/call_message.dart';

class CustomTheUserInfo extends StatelessWidget {
  const CustomTheUserInfo({
    super.key,
    this.hint,
    this.inProgress = false,
    this.withContactWidget = false,
    this.exporter,
    this.roomToken,
    this.shipmentId,
    this.shipmentCode,
    this.driverId,
  });
  final String? hint;
  final String? shipmentCode;
  final String? driverId;
  final bool inProgress;
  final bool withContactWidget;
  final DriverOrUserModel? exporter;
  final String? shipmentId;
  final String? roomToken;
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverShipmentsCubit>();
    return Row(
      children: [
        CustomNetworkImage(
          image: exporter?.image ?? "",
          isUser: true,
          height: 50.h,
          width: 50.h,
          borderRadius: 100.r,
        ),
        10.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exporter?.name ?? "اسم العميل",
                style: getMediumStyle(
                  fontSize: 14.sp,
                ),
              ),
              if (hint != null && hint!.isNotEmpty)
                Text(
                  hint!,
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
            ],
          ),
        ),
        10.w.horizontalSpace,
        if (withContactWidget)
          CustomCallAndMessageWidget(
            shipmentId: shipmentId,
            driverId: driverId,
            name: exporter?.name,
            roomToken: roomToken,
            shipmentCode: shipmentCode,
            phoneNumber: exporter?.phone.toString(),
          )
        else ...[
          inProgress
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    "pending".tr(),
                    style: getRegularStyle(
                      fontSize: 12.sp,
                      color: AppColors.secondPrimary,
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {
                    cubit.requestShipment(
                      shipmentId: shipmentId ?? "",
                      context: context,
                    );
                  },
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppColors.green,
                    child: Icon(
                      Icons.check,
                      color: AppColors.white,
                      // size: 20.r,
                    ),
                  ),
                ),
          if (inProgress) 10.w.horizontalSpace,
          if (inProgress)
            InkWell(
              onTap: () {
                warningDialog(context, title: "delete_shipment_sure".tr(),
                    onPressedOk: () {
                  cubit.cancelRequestShipment(
                    shipmentId: shipmentId ?? "",
                    context: context,
                  );
                });
              },
              child: CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.red,
                child: Icon(
                  Icons.close,
                  color: AppColors.white,
                  // size: 20.r,
                ),
              ),
            ),
        ]
      ],
    );
  }
}
