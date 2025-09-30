import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/appwidget.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/shipments/cubit/cubit.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import '../data/models/countries_and_types_model.dart';
import '../data/repo.dart';
import 'state.dart';

class AddNewShipmentCubit extends Cubit<AddNewShipmentState> {
  AddNewShipmentCubit(this.api) : super(AddNewShipmentInitState());

  AddNewShipmentRepo api;

  TextEditingController fromAddressController = TextEditingController();

  TextEditingController fromQtyController = TextEditingController();

  TextEditingController toQtyController = TextEditingController();

  TextEditingController shipmentTypeController = TextEditingController();

  TextEditingController selectedTimeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  GetCountriesAndTruckTypeModelData? toCountry;

  GetCountriesAndTruckTypeModelData? shipmentType;
  DateTime? selectedDate;
  List<GetCountriesAndTruckTypeModelData>? selectedCountriesAtEditProfile;

  void toCountryChanged(GetCountriesAndTruckTypeModelData? country) {
    toCountry = country;
    emit(ToCountryChanged());
  }

  //!

  Future<void> selectDateTime(BuildContext context) async {
    DateTime? initialDate;
    TimeOfDay initialTime = TimeOfDay.now();

    // Start date: use stored value or today
    try {
      final startDate = DateFormat('yyyy-MM-dd HH:mm:ss', 'en')
          .parse(selectedTimeController.text);
      initialDate = startDate;
      initialTime = TimeOfDay.fromDateTime(startDate);
    } catch (e) {
      initialDate = DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      locale: Locale('ar'),
      firstDate: DateTime.now(),
      keyboardType: TextInputType.datetime,
      lastDate: DateTime(50100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        selectedDate = finalDateTime;

        String formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(finalDateTime);

        selectedTimeController.text = formattedDateTime;

        emit(DateTimeSelected(formattedDateTime));
      }
    }
  }

  GetCountriesAndTruckTypeModel? allCountries;
  GetCountriesAndTruckTypeModel? allTruckType;
  Future<void> getCountriesAndTruckType(bool isGetTypes) async {
    try {
      emit(GetAllCountriesAndTruckTypesLoading());
      final res =
          await api.mainGetData(model: isGetTypes ? 'TruckType' : 'Country');
      res.fold((l) {
        errorGetBar(l.toString());
        emit(GetAllCountriesAndTruckTypesError());
      }, (r) {
        if (isGetTypes) {
          allTruckType = r;
        } else {
          allCountries = r;
          if (r.data?.isNotEmpty ?? false) {
            toCountry = r.data?.first;
          }
        }
        emit(GetAllCountriesAndTruckTypesLoaded());
      });
    } catch (e) {
      errorGetBar(e.toString());
      emit(GetAllCountriesAndTruckTypesError());
    }
  }

  addNewShipment(BuildContext context) async {
    try {
      AppWidget.createProgressDialog(context, msg: 'locading'.tr());
      emit(AddNewShipmentLoading());
      final res = await api.addNewShipment(
        description: descriptionController.text,
        from: fromAddressController.text,
        loadSizeFrom:
            fromQtyController.text.isNotEmpty ? fromQtyController.text : null,
        loadSizeTo:
            toQtyController.text.isNotEmpty ? toQtyController.text : null,
        shipmentDateTime: selectedTimeController.text,
        toCountryId: toCountry?.id.toString() ?? '',
        truckTypeId: shipmentType?.id.toString() ?? '',
        goodsType: shipmentTypeController.text,
        lat: context.read<LocationCubit>().selectedLocation?.latitude,
        long: context.read<LocationCubit>().selectedLocation?.longitude,
      );
      res.fold((l) {
        errorGetBar(l.toString());
        Navigator.pop(context);
        emit(AddNewShipmentError());
      }, (r) {
        if (r.status == 200) {
          successGetBar(r.msg ?? '');
          Navigator.pop(context);

          emit(AddNewShipmentLoaded());
          clearShipmentData();
          context.read<UserHomeCubit>().getHome(context);
        } else {
          errorGetBar(r.msg.toString());

          emit(AddNewShipmentError());
        }
        Navigator.pop(context);
      });
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);

      emit(AddNewShipmentError());
    }
  }

  clearShipmentData() {
    descriptionController.clear();
    fromAddressController.clear();
    fromQtyController.clear();
    toQtyController.clear();
    selectedTimeController.clear();
    toCountry = null;
    shipmentType = null;
    shipmentTypeController.clear();
  }

  updateShipment(BuildContext context, {required String id}) async {
    try {
      AppWidget.createProgressDialog(context, msg: 'locading'.tr());
      emit(AddNewShipmentLoading());
      final res = await api.updateShipment(
          description: descriptionController.text,
          from: fromAddressController.text,
          loadSizeFrom:
              fromQtyController.text.isNotEmpty ? fromQtyController.text : null,
          loadSizeTo:
              toQtyController.text.isNotEmpty ? toQtyController.text : null,
          shipmentDateTime: selectedTimeController.text,
          toCountryId: toCountry?.id.toString() ?? '',
          truckTypeId: shipmentType?.id.toString() ?? '',
          goodsType: shipmentTypeController.text,
          lat: context.read<LocationCubit>().selectedLocation?.latitude,
          long: context.read<LocationCubit>().selectedLocation?.longitude,
          shipmentId: id);
      res.fold((l) {
        errorGetBar(l.toString());
        Navigator.pop(context);
        emit(AddNewShipmentError());
      }, (r) {
        if (r.status == 200) {
          successGetBar(r.msg ?? '');
          Navigator.pop(context);
          context.read<UserShipmentsCubit>().getShipmentDetails(id: id);
          clearShipmentData();
          emit(AddNewShipmentLoaded());
        } else {
          errorGetBar(r.msg.toString());

          emit(AddNewShipmentError());
        }
        Navigator.pop(context);
      });
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);

      emit(AddNewShipmentError());
    }
  }
}
