import 'package:waslny/core/exports.dart';
import 'package:waslny/features/user/shipments/data/models/shipment_details.dart';
// import 'package:flutter_meta_sdk/flutter_meta_sdk.dart';

import '../../../general/location/screens/full_screen_map.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import '../data/models/countries_and_types_model.dart';

class AddShipmentsArgs {
  final UserShipmentData? shipment;

  AddShipmentsArgs({this.shipment});
}

class AddNewShipmentScreen extends StatefulWidget {
  const AddNewShipmentScreen({
    super.key,
    this.args,
  });
  final AddShipmentsArgs? args;
  @override
  State<AddNewShipmentScreen> createState() => _AddNewShipmentScreenState();
}

class _AddNewShipmentScreenState extends State<AddNewShipmentScreen> {
  @override
  void initState() {
    super.initState();

    final cubit = context.read<AddNewShipmentCubit>();
    final shipment = widget.args?.shipment;

    _initializeCountries(cubit, shipment);
    _initializeTruckTypes(cubit, shipment);

    if (shipment != null) {
      _populateControllers(cubit, shipment);
    }
  }

  void _initializeCountries(
      AddNewShipmentCubit cubit, UserShipmentData? shipment) {
    if (cubit.allCountries == null) {
      cubit.getCountriesAndTruckType(false).then((_) {
        _assignToCountry(cubit, shipment);
      });
    } else {
      _assignToCountry(cubit, shipment);
    }
  }

  void _initializeTruckTypes(
      AddNewShipmentCubit cubit, UserShipmentData? shipment) {
    if (cubit.allTruckType == null) {
      cubit.getCountriesAndTruckType(true).then((_) {
        _assignTruckType(cubit, shipment);
      });
    } else {
      _assignTruckType(cubit, shipment);
    }
  }

  void _assignToCountry(AddNewShipmentCubit cubit, UserShipmentData? shipment) {
    if (shipment == null) return;

    final countries = cubit.allCountries?.data;
    if (countries != null && countries.isNotEmpty) {
      for (var country in countries) {
        if (country.id == shipment.to?.id) {
          cubit.toCountry = country;
          break;
        }
      }
    }
  }

  void _assignTruckType(AddNewShipmentCubit cubit, UserShipmentData? shipment) {
    if (shipment == null) return;

    final truckTypes = cubit.allTruckType?.data;
    if (truckTypes != null && truckTypes.isNotEmpty) {
      for (var type in truckTypes) {
        if (type.id == shipment.truckType?.id) {
          cubit.shipmentType = type;
          break;
        }
      }
    }
  }

  void _populateControllers(
      AddNewShipmentCubit cubit, UserShipmentData shipment) {
    cubit.fromAddressController.text = shipment.from ?? '';
    cubit.descriptionController.text = shipment.description ?? '';
    cubit.shipmentTypeController.text = shipment.goodsType ?? '';
    cubit.selectedTimeController.text = shipment.shipmentDateTime ?? '';
    cubit.toQtyController.text = shipment.toSize?.toString() ?? '';
    cubit.fromQtyController.text = shipment.fromSize?.toString() ?? '';
  }

  var formKey = GlobalKey<FormState>();
  // static final metaSdk = FlutterMetaSdk();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewShipmentCubit, AddNewShipmentState>(
        builder: (context, state) {
      var cubit = context.read<AddNewShipmentCubit>();

      return Scaffold(
        appBar: customAppBar(context,
            title: widget.args?.shipment != null
                ? 'edit_shipment'.tr()
                : 'add_shipment'.tr()),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.args?.shipment != null) ...[
                  Text(
                    '${"code".tr()} ${widget.args?.shipment?.code ?? ""}',
                    style: getMediumStyle(
                      fontSize: 16.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  20.h.verticalSpace
                ],
                Text(
                  'what_is_distination'.tr(),
                  style: getSemiBoldStyle(),
                ),
                5.h.verticalSpace,
                CustomTextField(
                  title: 'from'.tr(),
                  isRequired: true,
                  controller: cubit.fromAddressController,
                  keyboardType: TextInputType.text,
                  hintText: 'select_location'.tr(),
                  suffixIcon: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullScreenMap()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          ImageAssets.mapIcon,
                          width: 20.h,
                          height: 20.h,
                        ),
                      )),
                  validationMessage: 'select_location'.tr(),
                ),
                5.h.verticalSpace,
                cubit.allCountries?.data?.length == 0
                    ? Container()
                    : CustomDropdownButtonFormField<
                        GetCountriesAndTruckTypeModelData>(
                        title: 'to'.tr(),
                        value: cubit.toCountry,
                        validationMessage: 'select_location'.tr(),
                        validator: (value) {
                          if (value == null) {
                            return 'select_location'.tr();
                          }
                          return null;
                        },
                        isRequired: true,
                        items: cubit.allCountries?.data ?? [],
                        itemBuilder: (item) {
                          return item.name ?? '';
                        },
                        onChanged: (value) {
                          cubit.toCountry = value;

                          // Handle the selected value
                        },
                      ),
                5.h.verticalSpace,
                cubit.allTruckType?.data?.length == 0
                    ? Container()
                    : CustomDropdownButtonFormField<
                        GetCountriesAndTruckTypeModelData>(
                        title: 'shipment_type'.tr(),
                        value: cubit.shipmentType,
                        validationMessage: 'select_location'.tr(),
                        validator: (value) {
                          if (value == null) {
                            return 'select_location'.tr();
                          }
                          return null;
                        },
                        isRequired: true,
                        items: cubit.allTruckType?.data ?? [],
                        itemBuilder: (item) {
                          return item.name ?? '';
                        },
                        onChanged: (value) {
                          cubit.shipmentType = value;
                          // Handle the selected value
                        },
                      ),
                5.h.verticalSpace,
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text('qty_of_shipment'.tr(), style: getMediumStyle()),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        isRequired: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        hintText: 'from'.tr(),
                        onChanged: (e) => validateQuantities(),
                        controller: cubit.fromQtyController,
                      ),
                    ),
                    10.w.horizontalSpace,
                    Expanded(
                      child: CustomTextField(
                        isRequired: false,
                        onChanged: (e) => validateQuantities(),
                        controller: cubit.toQtyController,
                        keyboardType: TextInputType.number,
                        hintText: 'to'.tr(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
                5.h.verticalSpace,
                CustomTextField(
                  title: 'goods_type'.tr(),
                  isRequired: true,
                  controller: cubit.shipmentTypeController,
                  keyboardType: TextInputType.text,
                  hintText: 'enter_shipment_type'.tr(),
                  validationMessage: 'enter_shipment_type'.tr(),
                ),
                5.h.verticalSpace,
                CustomTextField(
                  title: 'time_of_loading'.tr(),
                  isRequired: true,
                  isReadOnly: true,
                  suffixIcon: InkWell(
                    onTap: () {
                      cubit.selectDateTime(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(ImageAssets.dateTimeIcon,
                          height: 20.h, width: 20.h),
                    ),
                  ),
                  controller: cubit.selectedTimeController,
                  keyboardType: TextInputType.datetime,
                  hintText: 'yyyy-MM-dd',
                  onTap: () {
                    cubit.selectDateTime(context);
                  },
                  validationMessage: 'time_of_loading'.tr(),
                ),
                5.h.verticalSpace,
                CustomTextField(
                  controller: cubit.descriptionController,
                  title: "shipment_desc".tr(),
                  isMessage: true,
                  isRequired: true,
                  keyboardType: TextInputType.multiline,
                  validationMessage: 'enter_shipment_desc'.tr(),
                  hintText: 'enter_shipment_desc'.tr(),
                ),
                10.h.verticalSpace,
                CustomButton(
                  title: widget.args?.shipment != null
                      ? 'update'.tr()
                      : 'add'.tr(),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      if (validateQuantities() == true) {
                        errorGetBar('enter_valid_size'.tr());
                      } else {
                        if (widget.args?.shipment != null) {
                          cubit.updateShipment(context,
                              id: widget.args?.shipment?.id.toString() ?? '');
                        } else {
                          cubit.addNewShipment(context);
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
    });
  }

  String? errorMessage;
  bool validateQuantities() {
    var cubit = context.read<AddNewShipmentCubit>();
    final fromQty = int.tryParse(cubit.fromQtyController.text);
    final toQty = int.tryParse(cubit.toQtyController.text);

    if (fromQty == null || toQty == null) {
      setState(() {
        errorMessage = 'Please enter valid numbers.';
      });
      return false;
    }

    if (fromQty >= toQty) {
      setState(() {
        errorMessage = 'To quantity must be greater than from quantity.';
      });
      return true;
    } else {
      setState(() {
        errorMessage = '';
      });
      return false;
    }
  }
}
