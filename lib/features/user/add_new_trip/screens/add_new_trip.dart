import 'package:flutter_meta_sdk/flutter_meta_sdk.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/core/widgets/custom_divider.dart';
import 'package:waslny/extention.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/location/screens/from_to_screen_map.dart';
import 'package:waslny/features/user/add_new_trip/screens/all_latest_locations_screen.dart';
import 'package:waslny/features/user/add_new_trip/screens/widget/custom_location_widget.dart';
import 'package:waslny/features/user/add_new_trip/screens/widget/custom_time_gender_vehicle.dart';
import 'package:waslny/features/user/add_new_trip/screens/widget/latest_locations_widget.dart';
import 'package:waslny/features/user/trip_and_services/data/models/shipment_details.dart';
// import 'package:flutter_meta_sdk/flutter_meta_sdk.dart';

import '../../../general/location/screens/full_screen_map.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';

class AddTripArgs {
  final bool? isService;
  AddTripArgs({this.isService = false});
}

class AddNewTripScreen extends StatefulWidget {
  const AddNewTripScreen({super.key, this.args});
  final AddTripArgs? args;
  @override
  State<AddNewTripScreen> createState() => _AddNewTripScreenState();
}

class _AddNewTripScreenState extends State<AddNewTripScreen> {
  @override
  void initState() {
    super.initState();

    final cubit = context.read<AddNewTripCubit>();
    final cubit2 = context.read<LocationCubit>();
    cubit2.clearRouteData();
    cubit.clearTripData();
    cubit.gettMainLastestLocation((widget.args?.isService ?? false));
  }

  var formKey = GlobalKey<FormState>();
  static final metaSdk = FlutterMetaSdk();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewTripCubit, AddNewTripState>(
      builder: (context, state) {
        // var cubit = context.read<AddNewTripCubit>();
        final cubit = context.watch<AddNewTripCubit>();

        final isFemale = cubit.selectedGenderType == Gender.female;

        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: isFemale ? AppColors.pink : Colors.white,
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: isFemale ? AppColors.pink : AppColors.primary,
            ),
          ),
          child: Scaffold(
            backgroundColor: isFemale
                ? const Color.fromARGB(255, 236, 173, 194)
                : Colors.white,
            appBar: customAppBar(
              context,
              titleWidget: widget.args?.isService == true
                  ? Text(
                      'add_service'.tr(),
                      style: getSemiBoldStyle(
                        color: AppColors.secondPrimary,
                        fontweight: FontWeight.w700,
                      ),
                    )
                  : MySvgWidget(
                      path: AppIcons.waslnyArIcon,
                      imageColor: AppColors.secondPrimary,
                    ),
              title: 'add_trip'.tr(),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(12.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///!START FROM AND TO
                    LocationInputWidget(
                      isService: widget.args?.isService ?? false,
                      fromController: cubit.fromAddressController,
                      toController: cubit.toAddressController,
                      onFromTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => (widget.args?.isService ?? false)
                                ? FullScreenMap()
                                : FromToScreenMap(isTo: false),
                          ),
                        );
                      },
                      onToTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FromToScreenMap(isTo: true),
                          ),
                        );
                      },
                    ),

                    ///! END FROM AND TO
                    5.h.verticalSpace,

                    ///! Time - Gender - Vehicle
                    ResponsiveTimeGenderVehicleDropdowns(
                      isService: widget.args?.isService ?? false,
                      selectedGenderType: cubit.selectedGenderType,
                      selectedTimeType: cubit.selectedTimeType,
                      selectedVehicleType: cubit.selectedVehicleType,
                      onTimeTypeChanged: (value) {
                        setState(() {
                          cubit.selectedTimeType = value;
                          if (cubit.selectedTimeType == TimeType.now) {
                            cubit.selectedDateController.clear();
                            cubit.selectedTimeController.clear();
                            cubit.selectedDate = null;
                            cubit.selectedTime = null;
                          }
                        });
                      },
                      onGenderTypeChanged: (value) {
                        cubit.selectedGenderType = value;
                        setState(() {});
                      },
                      onVehicleTypeChanged: (value) {
                        cubit.selectedVehicleType = value;
                      },
                      selectedServiceTo: cubit.selectedServiceTo,
                      onServiceToChanged: (value) {
                        setState(() {
                          cubit.selectedServiceTo = value;
                        });
                      },
                    ),

                    ///! END Time - Gender - Vehicle
                    5.h.verticalSpace,
                    if (cubit.selectedTimeType == TimeType.later)
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: CustomTextField(
                              borderRadius: 20.r,
                              isRequired: false,
                              textAlign: TextAlign.center,
                              isReadOnly: true,

                              controller: cubit.selectedDateController,
                              keyboardType: TextInputType.datetime,
                              hintText: 'YYYY-MM-DD',
                              onTap: () {
                                cubit.selectDate(context);
                              },
                              validationMessage: 'date_is_required'.tr(),
                            ),
                          ),
                          10.w.horizontalSpace,
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              borderRadius: 20.r,

                              isRequired: false,
                              isReadOnly: true,
                              textAlign: TextAlign.center,

                              controller: cubit.selectedTimeController,
                              keyboardType: TextInputType.datetime,
                              hintText: 'time'.tr(),
                              onTap: () {
                                cubit.selectTime(context);
                              },
                              validationMessage: 'time_is_required'.tr(),
                            ),
                          ),
                        ],
                      ),
                    5.h.verticalSpace,
                    if (widget.args?.isService == true) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.amberAccent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: getSemiBoldStyle(fontSize: 12.sp),
                                children: [
                                  const TextSpan(
                                    text:
                                        'يتم احتساب خدمة شحن مدكور / طلب المشتريات بقيمة (',
                                  ),
                                  TextSpan(
                                    text: '45 جنيهاً',
                                    style: getSemiBoldStyle(
                                      fontSize: 12.sp,
                                      fontweight: FontWeight.w800,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ') للمحل الواحد، مع إضافة ',
                                  ),
                                  TextSpan(
                                    text: '10 جنيهاً',
                                    style: getSemiBoldStyle(
                                      fontSize: 12.sp,
                                      fontweight: FontWeight.w800,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' لكل محل إضافي ضمن نفس الطلب.',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      5.h.verticalSpace,
                    ],

                    CustomTextField(
                      controller: cubit.descriptionController,

                      isMessage: true,
                      borderRadius: 20.r,
                      isRequired: false,
                      keyboardType: TextInputType.multiline,

                      hintText: 'enter_trip_desc'.tr(),
                    ),
                    10.h.verticalSpace,

                    //! LIST OF LATEST LOCATIONS
                    state is LoadingGetLatestLocation
                        ? LinearProgressIndicator(
                            color: AppColors.secondPrimary,
                            backgroundColor: AppColors.primary,
                          )
                        : LatestLocationsWidgets(cubit: cubit),

                    //! SELECT FROM LOCATION
                    CustomDivider(),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => FullScreenMap(
                    //           isTo: widget.args?.isService == false,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10.r),
                    //       color: AppColors.second2Primary,
                    //     ),
                    //     padding: const EdgeInsets.all(8.0),
                    //     margin: const EdgeInsets.symmetric(vertical: 2.0),
                    //     child: Row(
                    //       children: [
                    //         Container(
                    //           decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(10.r),
                    //             color: AppColors.second3Primary,
                    //           ),
                    //           padding: EdgeInsets.all(8),
                    //           child: MySvgWidget(path: AppIcons.selectLocation),
                    //         ),
                    //         10.w.horizontalSpace,
                    //         // Flexible(
                    //         //   child: Text(
                    //         //     widget.args?.isService == true
                    //         //         ? 'from_map'.tr()
                    //         //         : 'select_location_from_map'.tr(),
                    //         //     style: getSemiBoldStyle(fontSize: 14.sp),
                    //         //     maxLines: 1,
                    //         //   ),
                    //         // ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    //! GET FROM SAVED LOCATIONS
                    if ((cubit.latestLocation?.data?.length ?? 0) > 3)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlllatestLocationsScreen(),
                            ),
                          );
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
                                child: MySvgWidget(
                                  path: AppIcons.savedLocations,
                                ),
                              ),
                              10.w.horizontalSpace,
                              Flexible(
                                child: Text(
                                  'saved_locations'.tr(),
                                  style: getSemiBoldStyle(fontSize: 14.sp),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ), //!
                    10.h.verticalSpace,
                    CustomButton(
                      title: 'add'.tr(),
                      btnColor: cubit.selectedGenderType == Gender.male
                          ? AppColors.primary
                          : AppColors.pink,
                      textColor: cubit.selectedGenderType == Gender.male
                          ? AppColors.secondPrimary
                          : AppColors.white,
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          if (cubit.selectedDateController.text.isEmpty &&
                              cubit.selectedTimeType == TimeType.later) {
                            errorGetBar('date_is_required'.tr());
                          } else if (cubit
                                  .selectedTimeController
                                  .text
                                  .isEmpty &&
                              cubit.selectedTimeType == TimeType.later) {
                            errorGetBar('time_is_required'.tr());
                          } else {
                            await cubit.addNewTrip(
                              context,
                              isService: widget.args?.isService ?? false,
                            );
                            await metaSdk.logEvent(
                              name: 'add_trip',
                              parameters: {
                                "trip_type": widget.args?.isService == true
                                    ? 'service'
                                    : 'trip',
                                'from': cubit.fromAddressController.text,
                                'to': cubit.toAddressController.text,
                                'description': cubit.descriptionController.text,

                                if (((widget.args?.isService ?? false) ==
                                            true) ==
                                        false &&
                                    cubit.distance != null)
                                  "distance": ((cubit.distance ?? 0) / 1000),
                                if (cubit.fromSelectedLocation?.latitude !=
                                    null)
                                  "from_lat":
                                      cubit.fromSelectedLocation?.latitude,
                                if (cubit.fromSelectedLocation?.longitude !=
                                    null)
                                  "from_long":
                                      cubit.fromSelectedLocation?.longitude,

                                if (((widget.args?.isService ?? false) ==
                                        true) ==
                                    false)
                                  "to": cubit.selectedServiceTo?.name,
                                if (cubit.toSelectedLocation?.latitude !=
                                        null &&
                                    ((widget.args?.isService ?? false) ==
                                            true) ==
                                        false)
                                  "to_lat": cubit.toSelectedLocation?.latitude,
                                if (cubit.toSelectedLocation?.latitude !=
                                        null &&
                                    ((widget.args?.isService ?? false) ==
                                            true) ==
                                        false)
                                  "to_long": cubit.toSelectedLocation?.latitude,

                                "prefer_driver_gender":
                                    cubit.selectedGenderType?.name,
                                "vehicle_type": cubit.selectedVehicleType?.name,

                                "type":
                                    (cubit.selectedTimeType?.name ==
                                        TimeType.later.name)
                                    ? "later"
                                    : "now",
                                if (cubit.selectedTimeType?.name ==
                                    TimeType.later.name)
                                  "schedule_time":
                                      cubit.selectedTimeType?.name ==
                                          TimeType.later.name
                                      ? DateFormat(
                                          'yyyy-MM-dd HH:mm:ss',
                                          'en',
                                        ).format(
                                          DateTime(
                                            cubit.selectedDate!.year,
                                            cubit.selectedDate!.month,
                                            cubit.selectedDate!.day,
                                            cubit.selectedTime!.hour,
                                            cubit.selectedTime!.minute,
                                          ),
                                        )
                                      : null,

                                "is_service": widget.args?.isService ?? false
                                    ? "1"
                                    : "0",
                                if ((widget.args?.isService ?? false) == true)
                                  "service_to": cubit.selectedServiceTo?.name
                                      .toString(),
                              },
                            );
                          }
                        }
                      },
                    ),
                    10.h.verticalSpace,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
