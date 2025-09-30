abstract class AddNewShipmentState {}

class AddNewShipmentInitState extends AddNewShipmentState {}

class DateTimeSelected extends AddNewShipmentState {
  String? formattedDateTime;
  DateTimeSelected(this.formattedDateTime);
}

class GetAllCountriesAndTruckTypesLoading extends AddNewShipmentState {}

class GetAllCountriesAndTruckTypesLoaded extends AddNewShipmentState {}

class GetAllCountriesAndTruckTypesError extends AddNewShipmentState {}

class AddNewShipmentLoading extends AddNewShipmentState {}

class AddNewShipmentLoaded extends AddNewShipmentState {}

class AddNewShipmentError extends AddNewShipmentState {}
class ToCountryChanged extends AddNewShipmentState {}
