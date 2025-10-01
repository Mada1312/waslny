import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/shipments/cubit/cubit.dart';
import 'package:waslny/features/user/shipments/cubit/cubit.dart';
import 'package:waslny/features/user/shipments/cubit/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void showAddRateBottomSheet(BuildContext context,
    {required String participantId,
    required String shipmentId,
    required bool isDriver}) {
  context.read<UserShipmentsCubit>().rateCommentController.clear();

  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      var cubit = context.read<UserShipmentsCubit>();
      GlobalKey<FormState> formKey = GlobalKey<FormState>();

      return BlocBuilder<UserShipmentsCubit, UserShipmentsState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              left: 20.w,
              right: 20.w,
              top: 20.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    !isDriver ? "rate_driver".tr() : "rate_user".tr(),
                    style: getSemiBoldStyle(
                      fontSize: 24.sp,
                    ),
                  ),
                  20.verticalSpace,
                  RatingBar.builder(
                    initialRating: cubit.rateValue,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30.sp,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    itemBuilder: (context, _) => Icon(
                      CupertinoIcons.star_fill,
                      color: Colors.yellow,
                    ),
                    onRatingUpdate: (rating) {
                      cubit.changeRateValue(rating);
                    },
                  ),
                  20.verticalSpace,
                  CustomTextField(
                    hintText: "write_comment".tr(),
                    isMessage: true,
                    isRequired: false,
                    controller: cubit.rateCommentController,
                  ),
                  20.verticalSpace,
                  CustomButton(
                    title: "send".tr(),
                    onPressed: () {
                      if (isDriver) {
                        context.read<DriverShipmentsCubit>().addRateForUser(
                            shipmentId: shipmentId,
                            context: context,
                            comment: cubit.rateCommentController.text,
                            userId: participantId,
                            rate: cubit.rateValue);
                      } else {
                        context.read<UserShipmentsCubit>().addRateForDriver(
                            shipmentId: shipmentId,
                            context: context,
                            comment: cubit.rateCommentController.text,
                            driverId: participantId,
                            rate: cubit.rateValue);
                      }

                      // cubit.addRate(context , reservationId:reservationId, id: context.read<MyReservationsCubit>().getResidenceReservationDetailsModel.data?.lodgeId??0);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
