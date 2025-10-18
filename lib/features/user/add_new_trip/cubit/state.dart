abstract class AddNewTripState {}

class AddNewTripInitState extends AddNewTripState {}

class DateTimeSelected extends AddNewTripState {
  String? formattedDateTime;
  DateTimeSelected(this.formattedDateTime);
}

class GetAllCountriesAndTruckTypesLoading extends AddNewTripState {}

class GetAllCountriesAndTruckTypesLoaded extends AddNewTripState {}

class GetAllCountriesAndTruckTypesError extends AddNewTripState {}

class AddNewTripLoading extends AddNewTripState {}

class AddNewTripLoaded extends AddNewTripState {}

class AddNewTripError extends AddNewTripState {}

class ToCountryChanged extends AddNewTripState {}
