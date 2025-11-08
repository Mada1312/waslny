// import 'package:waslny/core/exports.dart';
// import 'package:waslny/core/widgets/my_svg_widget.dart';
// import 'package:waslny/features/driver/trips/data/models/shipment_details_model.dart';
// import 'package:waslny/features/user/trip_and_services/screens/widgets/custom_from_to.dart';

// class ShipmentDetailsDriverBody extends StatelessWidget {
//   const ShipmentDetailsDriverBody({super.key, this.shipmentDetails});
//   final ShipmentDetailsDriverData? shipmentDetails;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '${"code".tr()} ${shipmentDetails?.code ?? ""}',
//           style: getMediumStyle(fontSize: 16.sp, color: AppColors.primary),
//         ),
//         20.h.verticalSpace,
//         CustomFromToWidget(
//           from: shipmentDetails?.from,
//           to: shipmentDetails?.toCountry?.name,
//           fromLat: shipmentDetails?.lat,
//           toLat: null,
//           toLng: null,
//           fromLng: shipmentDetails?.long,
//         ),
//         10.h.verticalSpace,
//         Divider(color: AppColors.grey.withOpacity(0.3), height: 1),
//         30.h.verticalSpace,
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ShipmentInfo(
//               title: 'shipment_type'.tr(),
//               value: shipmentDetails?.truckType?.name ?? "نوع الشحنة",
//               icon: AppIcons.shipmentType,
//             ),
//             20.w.horizontalSpace,
//             ShipmentInfo(
//               title: 'cargo_volume'.tr(),
//               value:
//                   "${shipmentDetails?.loadSizeFrom.toString() ?? "0"} - ${shipmentDetails?.loadSizeTo.toString() ?? "0"} ${"tons".tr()}",
//               icon: AppIcons.shipmentSize,
//               imageColor: null,
//             ),
//           ],
//         ),
//         20.h.verticalSpace,
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ShipmentInfo(
//               title: 'date'.tr(),
//               value:
//                   formatDate(shipmentDetails?.shipmentDateTime) ?? "01/01/2023",
//               icon: AppIcons.date,
//             ),
//             20.w.horizontalSpace,
//             ShipmentInfo(
//               title: 'time'.tr(),
//               value:
//                   formatTime(shipmentDetails?.shipmentDateTime) ?? "10:00 AM",
//               icon: AppIcons.time,
//             ),
//           ],
//         ),
//         20.h.verticalSpace,
//         Divider(color: AppColors.grey.withOpacity(0.3), height: 1),
//         30.h.verticalSpace,
//         Text("goods_type".tr(), style: getMediumStyle(fontSize: 16.sp)),
//         10.h.verticalSpace,
//         Text(
//           "    ${shipmentDetails?.goodsType ?? " "}",
//           style: getRegularStyle(fontSize: 16.sp, color: AppColors.darkGrey),
//         ),
//         20.h.verticalSpace,
//         Text("trip_details".tr(), style: getMediumStyle(fontSize: 16.sp)),
//         10.h.verticalSpace,
//         Text(
//           "    ${shipmentDetails?.description ?? " "}",
//           style: getRegularStyle(fontSize: 16.sp, color: AppColors.darkGrey),
//         ),
//       ],
//     );
//   }
// }

// class ShipmentInfo extends StatelessWidget {
//   const ShipmentInfo({
//     super.key,
//     required this.title,
//     required this.value,
//     this.imageColor,
//     required this.icon,
//   });

//   final String title;
//   final String value;
//   final String icon;
//   final Color? imageColor;

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           imageColor == null
//               ? MySvgWidget(path: icon, height: 25.h, width: 25.h)
//               : MySvgWidget(
//                   path: icon,
//                   height: 25.h,
//                   width: 25.h,
//                   imageColor: AppColors.dark2Grey,
//                 ),
//           10.w.horizontalSpace,
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: getMediumStyle(fontSize: 14.sp)),
//                 5.h.verticalSpace,
//                 Text(
//                   value,
//                   style: getRegularStyle(
//                     fontSize: 16.sp,
//                     color: AppColors.darkGrey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
