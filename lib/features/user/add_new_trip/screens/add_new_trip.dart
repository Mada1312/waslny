import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/extention.dart';
import 'package:waslny/features/user/add_new_trip/screens/widget/custom_location_widget.dart';
import 'package:waslny/features/user/add_new_trip/screens/widget/custom_time_gender_vehicle.dart';
import 'package:waslny/features/user/trip_and_services/data/models/shipment_details.dart';
// import 'package:flutter_meta_sdk/flutter_meta_sdk.dart';

import '../../../general/location/screens/full_screen_map.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';

class AddTripArgs {
  final UserShipmentData? shipment;
  final bool? isService;
  AddTripArgs({this.isService = false, this.shipment});
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

    // final cubit = context.read<AddNewTripCubit>();
    // final shipment = widget.args?.shipment;

    // _initializeCountries(cubit, shipment);
    // _initializeTruckTypes(cubit, shipment);

    // if (shipment != null) {
    //   _populateControllers(cubit, shipment);
    // }
  }

  // void _initializeCountries(AddNewTripCubit cubit, UserShipmentData? shipment) {
  //   if (cubit.allCountries == null) {
  //     cubit.getCountriesAndTruckType(false).then((_) {
  //       _assignToCountry(cubit, shipment);
  //     });
  //   } else {
  //     _assignToCountry(cubit, shipment);
  //   }
  // }

  // void _initializeTruckTypes(
  //   AddNewTripCubit cubit,
  //   UserShipmentData? shipment,
  // ) {
  //   if (cubit.allTruckType == null) {
  //     cubit.getCountriesAndTruckType(true).then((_) {
  //       _assignTruckType(cubit, shipment);
  //     });
  //   } else {
  //     _assignTruckType(cubit, shipment);
  //   }
  // }

  // void _assignToCountry(AddNewTripCubit cubit, UserShipmentData? shipment) {
  //   if (shipment == null) return;

  //   final countries = cubit.allCountries?.data;
  //   if (countries != null && countries.isNotEmpty) {
  //     for (var country in countries) {
  //       if (country.id == shipment.to?.id) {
  //         cubit.toCountry = country;
  //         break;
  //       }
  //     }
  //   }
  // }

  // void _assignTruckType(AddNewTripCubit cubit, UserShipmentData? shipment) {
  //   if (shipment == null) return;

  //   final truckTypes = cubit.allTruckType?.data;
  //   if (truckTypes != null && truckTypes.isNotEmpty) {
  //     for (var type in truckTypes) {
  //       if (type.id == shipment.truckType?.id) {
  //         cubit.shipmentType = type;
  //         break;
  //       }
  //     }
  //   }
  // }

  // void _populateControllers(AddNewTripCubit cubit, UserShipmentData shipment) {
  //   cubit.fromAddressController.text = shipment.from ?? '';
  //   cubit.descriptionController.text = shipment.description ?? '';
  //   cubit.shipmentTypeController.text = shipment.goodsType ?? '';
  //   cubit.selectedTimeController.text = shipment.shipmentDateTime ?? '';
  //   cubit.toQtyController.text = shipment.toSize?.toString() ?? '';
  //   cubit.fromQtyController.text = shipment.fromSize?.toString() ?? '';
  // }

  var formKey = GlobalKey<FormState>();
  // static final metaSdk = FlutterMetaSdk();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewTripCubit, AddNewTripState>(
      builder: (context, state) {
        var cubit = context.read<AddNewTripCubit>();

        return Scaffold(
          appBar: customAppBar(
            context,
            titleWidget: MySvgWidget(
              path: AppIcons.waslnyArIcon,
              imageColor: AppColors.secondPrimary,
            ),
            title: widget.args?.shipment != null
                ? 'edit_trip'.tr()
                : 'add_trip'.tr(),
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
                    fromController: cubit.fromAddressController,
                    toController: cubit.toAddressController,
                    onFromTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FullScreenMap()),
                      );
                    },
                    onToTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenMap(isTo: true),
                        ),
                      );
                    },
                  ),

                  ///! END FROM AND TO
                  5.h.verticalSpace,

                  ///! Time - Gender - Vehicle
                  ResponsiveTimeGenderVehicleDropdowns(
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
                    },
                    onVehicleTypeChanged: (value) {
                      cubit.selectedVehicleType = value;
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
                  //! SELECT FROM LOCATION
                  //! GET FROM SAVED LOCATIONS
                  10.h.verticalSpace,
                  CustomButton(
                    title: widget.args?.shipment != null
                        ? 'update'.tr()
                        : 'add'.tr(),
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        if (cubit.selectedDateController.text.isEmpty &&
                            cubit.selectedTimeType == TimeType.later) {
                          errorGetBar('date_is_required'.tr());
                        } else if (cubit.selectedTimeController.text.isEmpty &&
                            cubit.selectedTimeType == TimeType.later) {
                          errorGetBar('time_is_required'.tr());
                        } else {
                          if (widget.args?.shipment != null) {
                            cubit.updateShipment(
                              context,
                              id: widget.args?.shipment?.id.toString() ?? '',
                            );
                          } else {
                            cubit.addNewTrip(
                              context,
                              isService: widget.args?.isService ?? false,
                            );
                            // await metaSdk.logEvent(
                            //   name: 'add_new_shipment',
                            //   parameters: {
                            //     'from': cubit.fromAddressController.text,
                            //     'to': cubit.toCountry?.name ?? '',
                            //     'shipment_type': cubit.shipmentType?.name ?? '',
                            //     'from_qty': cubit.fromQtyController.text,
                            //     'to_qty': cubit.toQtyController.text,
                            //     'goods_type': cubit.shipmentTypeController.text,
                            //     'loading_time': cubit.selectedTimeController.text,
                            //     'description': cubit.descriptionController.text,
                            //   },
                            // );
                          }
                        }
                      }
                    },
                  ),
                  10.h.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
