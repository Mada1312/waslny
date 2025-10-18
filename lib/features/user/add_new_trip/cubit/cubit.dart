import 'dart:developer';

import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:location/location.dart' as loc;
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';

import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import '../data/models/countries_and_types_model.dart';
import '../data/repo.dart';
import 'state.dart';

class AddNewTripCubit extends Cubit<AddNewTripState> {
  AddNewTripCubit(this.api) : super(AddNewTripInitState());

  AddNewTripRepo api;
  //!TRIP
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController toAddressController = TextEditingController();
  loc.LocationData? fromSelectedLocation;
  loc.LocationData? toSelectedLocation;

  TimeType? selectedTimeType = TimeType.now;
  Gender? selectedGenderType = Gender.male;
  VehicleType? selectedVehicleType = VehicleType.car;
  //!TRIP

  TextEditingController selectedDateController = TextEditingController();
  TextEditingController selectedTimeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<GetCountriesAndTruckTypeModelData>? selectedCountriesAtEditProfile;

  //!

  Future<void> selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat(
        'yyyy-MM-dd',
        'en',
      ).parse(selectedDateController.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      locale: const Locale('ar'),
      firstDate: DateTime.now(),
      lastDate: DateTime(50100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyLarge: getRegularStyle(),
              bodyMedium: getRegularStyle(),
              bodySmall: getRegularStyle(),
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.secondPrimary,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      selectedDateController.text = DateFormat(
        'yyyy-MM-dd',
        'en',
      ).format(pickedDate);
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyLarge: getRegularStyle(),
              bodyMedium: getRegularStyle(),
              bodySmall: getRegularStyle(),
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.secondPrimary,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      selectedTime = pickedTime;
      selectedTimeController.text = pickedTime.format(context);
    }
  }

  // Future<void> selectDateTime(BuildContext context) async {
  //   await selectDate(context);
  //   if (selectedDate != null) {
  //     await selectTime(context);
  //     if (selectedTime != null) {
  // final DateTime finalDateTime = DateTime(
  //   selectedDate!.year,
  //   selectedDate!.month,
  //   selectedDate!.day,
  //   selectedTime!.hour,
  //   selectedTime!.minute,
  // );

  // final String formattedDateTime = DateFormat(
  //   'yyyy-MM-dd HH:mm:ss',
  //   'en',
  // ).format(finalDateTime);

  //       selectedTimeController.text = formattedDateTime;
  //       emit(DateTimeSelected(formattedDateTime));
  //     }
  //   }
  // }

  addNewTrip(BuildContext context, {bool isService = false}) async {
    try {
      if (selectedTimeType?.name == TimeType.later.name) {
        log(
          'TIME ${DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute))}',
        );
      }

      AppWidget.createProgressDialog(context, msg: 'locading'.tr());
      emit(AddNewTripLoading());
      final res = await api.addNewTrip(
        description: descriptionController.text,
        from: fromAddressController.text,
        gender: selectedGenderType?.name == Gender.male.name ? '0' : '1',
        isSchedule: selectedTimeType?.name == TimeType.later.name,
        isService: isService,
        serviceTo: toAddressController.text,
        scheduleTime: selectedTimeType?.name == TimeType.later.name
            ? DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(
                DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                ),
              )
            : null,
        to: toAddressController.text,
        vehicleType: selectedVehicleType?.name == VehicleType.car.name
            ? 'car'
            : 'scooter',
        toLat: toSelectedLocation?.latitude,
        toLong: toSelectedLocation?.longitude,
        fromLat: fromSelectedLocation?.latitude,
        fromLong: fromSelectedLocation?.longitude,
      );
      res.fold(
        (l) {
          errorGetBar(l.toString());
          Navigator.pop(context);
          emit(AddNewTripError());
        },
        (r) {
          if (r.status == 200) {
            successGetBar(r.msg ?? '');
            Navigator.pop(context);

            emit(AddNewTripLoaded());
            clearTripData();
            context.read<UserHomeCubit>().getHome(context);
          } else {
            errorGetBar(r.msg.toString());

            emit(AddNewTripError());
          }
          Navigator.pop(context);
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);

      emit(AddNewTripError());
    }
  }

  clearTripData() {
    descriptionController.clear();
    fromAddressController.clear();
    selectedTimeController.clear();
    toAddressController.clear();
    selectedGenderType = Gender.male;
    selectedTimeType = TimeType.now;
    selectedVehicleType = VehicleType.car;
    toSelectedLocation = null;
    fromSelectedLocation = null;
    selectedDate = null;
    selectedTime = null;
    fromSelectedLocation = null;
    toSelectedLocation = null;
    selectedDateController.clear();
  }

  updateShipment(BuildContext context, {required String id}) async {
    try {
      AppWidget.createProgressDialog(context, msg: 'locading'.tr());
      emit(AddNewTripLoading());
      final res = await api.updateTrip(
        description: descriptionController.text,
        from: fromAddressController.text,
        loadSizeFrom: null,
        loadSizeTo: null,
        shipmentDateTime: selectedTimeController.text,
        toCountryId: '',
        truckTypeId: '',
        goodsType: "shipmentTypeController.text",
        lat: context.read<LocationCubit>().selectedLocation?.latitude,
        long: context.read<LocationCubit>().selectedLocation?.longitude,
        shipmentId: id,
      );
      res.fold(
        (l) {
          errorGetBar(l.toString());
          Navigator.pop(context);
          emit(AddNewTripError());
        },
        (r) {
          if (r.status == 200) {
            successGetBar(r.msg ?? '');
            Navigator.pop(context);
            context.read<UserTripAndServicesCubit>().getShipmentDetails(id: id);
            clearTripData();
            emit(AddNewTripLoaded());
          } else {
            errorGetBar(r.msg.toString());

            emit(AddNewTripError());
          }
          Navigator.pop(context);
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);

      emit(AddNewTripError());
    }
  }
}
