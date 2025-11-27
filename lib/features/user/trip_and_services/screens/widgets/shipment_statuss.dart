// import 'package:waslny/core/exports.dart';
// import 'package:waslny/features/exporter/shipments/cubit/cubit.dart';
// import 'package:waslny/features/exporter/shipments/cubit/state.dart';

// class CustomShipmentsTypes extends StatelessWidget {
//   const CustomShipmentsTypes({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var cubit = context.read<ExporterShipmentsCubit>();
//     return BlocBuilder<ExporterShipmentsCubit, ExporterShipmentsState>(
//       builder: (context, state) {
//         return SizedBox(
//           height: 50.h,
//           child: ListView.builder(
//             itemCount: shipmentsStatusList.length,
//             scrollDirection: Axis.horizontal,
//             itemBuilder: (context, index) => GestureDetector(
//               onTap: () {
//                 cubit.changeSelectedStatus(
//                   shipmentsStatusList[index].status,
//                 );
//               },
//               child: Padding(
//                 padding: EdgeInsetsDirectional.only(start: 10.w),
//                 child: Container(
//                     height: 50.h,
//                     decoration: BoxDecoration(
//                       color: cubit.selectedStatus ==
//                               shipmentsStatusList[index].status
//                           ? AppColors.primary
//                           : AppColors.darkGrey,
//                       borderRadius: BorderRadius.circular(100.r),
//                     ),
//                     child: Center(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 20.w,
//                         ),
//                         child: Text(
//                           shipmentsStatusList[index].title,
//                           style: getMediumStyle(
//                             fontSize: 16.sp,
//                             color: AppColors.white,
//                           ),
//                         ),
//                       ),
//                     )),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:waslny/core/exports.dart';
// import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
// import 'package:waslny/features/user/trip_and_services/cubit/state.dart';
// import 'package:flutter/cupertino.dart';

// List<ShipMentsStatus> shipmentsStatusList = [
//   ShipMentsStatus(title: 'new'.tr(), status: ShipmentsStatusEnum.newShipments),
//   ShipMentsStatus(title: 'pending'.tr(), status: ShipmentsStatusEnum.pending),
//   ShipMentsStatus(title: 'loaded'.tr(), status: ShipmentsStatusEnum.loaded),
//   ShipMentsStatus(
//     title: 'delivered'.tr(),
//     status: ShipmentsStatusEnum.delivered,
//   ),
// ];

// class CustomShipmentsTypes extends StatelessWidget {
//   const CustomShipmentsTypes({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var cubit = context.read<UserTripAndServicesCubit>();
//     return BlocBuilder<UserTripAndServicesCubit, UserTripAndServicesState>(
//       builder: (context, state) {
//         return Padding(
//           padding: EdgeInsetsDirectional.only(
//             start: getHorizontalPadding(context),
//           ),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             decoration: BoxDecoration(
//               border: Border.all(color: AppColors.primary, width: 1.w),
//               borderRadius: BorderRadius.circular(100.r),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<ShipMentsStatus>(
//                 value: shipmentsStatusList.firstWhere(
//                   (element) => element.status == cubit.selectedStatus,
//                   orElse: () => shipmentsStatusList[0],
//                 ),
//                 items: shipmentsStatusList.map((ShipMentsStatus status) {
//                   return DropdownMenuItem<ShipMentsStatus>(
//                     value: status,
//                     child: Text(
//                       status.title,
//                       style: getMediumStyle(
//                         fontSize: 16.sp,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (ShipMentsStatus? newValue) {
//                   if (newValue != null) {
//                     cubit.changeSelectedStatus(newValue.status);
//                   }
//                 },
//                 dropdownColor: AppColors.white,
//                 // iconEnabledColor: AppColors.primary,
//                 icon: Icon(
//                   CupertinoIcons.chevron_down,
//                   size: 20.w,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
