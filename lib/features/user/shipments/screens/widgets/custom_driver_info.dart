import 'package:waslny/core/exports.dart';

import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:flutter/cupertino.dart';

import '../../../driver_details/screens/driver_details.dart';
import 'call_message.dart';

class CustomDriverInfo extends StatefulWidget {
  const CustomDriverInfo({
    super.key,
    this.hint,
    this.driver,
    this.shipmentCode,
    this.roomToken,
    this.shipmentId,
    this.isFavWidget,
  });
  final String? hint;
  final String? shipmentCode;
  final String? shipmentId;
  final String? roomToken;
  final DriverOrUserModel? driver;
  final bool? isFavWidget;

  @override
  State<CustomDriverInfo> createState() => _CustomDriverInfoState();
}

class _CustomDriverInfoState extends State<CustomDriverInfo> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverDetailsScreenById(
                driverId: widget.driver?.driverId?.toString() ??
                    widget.driver?.id?.toString() ??
                    '',
              ),
            ));
      },
      child: Row(
        children: [
          CustomNetworkImage(
            image: widget.driver?.image ?? '',
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.driver?.name ?? "اسم السائق",
                        style: getMediumStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    if (widget.isFavWidget != null) 10.w.horizontalSpace,
                    if (widget.isFavWidget != null)
                      InkWell(
                          onTap: () {
                            setState(() {
                              if (widget.driver?.isFav != null) {
                                widget.driver?.isFav = !widget.driver!.isFav!;
                              }
                            });
                            context
                                .read<ProfileCubit>()
                                .actionFav(widget.driver?.id?.toString() ?? '');
                            //! remove form fav
                          },
                          child: Icon(
                            CupertinoIcons.heart_fill,
                            color: widget.driver?.isFav ?? false
                                ? AppColors.red
                                : AppColors.darkGrey,
                          )),
                  ],
                ),
                if (widget.hint != null)
                  Text(
                    widget.hint!,
                    style: getRegularStyle(
                      fontSize: 12.sp,
                      color: AppColors.darkGrey,
                    ),
                  ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          CustomCallAndMessageWidget(
            driverId: widget.driver?.driverId?.toString() ??
                widget.driver?.id?.toString(),
            name: widget.driver?.name ?? '',
            shipmentId: widget.shipmentId,
            roomToken: widget.roomToken,
            shipmentCode: widget.shipmentCode,
            phoneNumber: widget.driver?.phone.toString(),
          ),
        ],
      ),
    );
  }
}
