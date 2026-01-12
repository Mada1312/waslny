import 'package:waslny/core/real-time/realtime_api.dart';

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

class LoadingGetLatestLocation extends AddNewTripState {}

class LoadedGetLatestLocation extends AddNewTripState {}

class ErrorGetLatestLocation extends AddNewTripState {}

class SuccessSelectedLocationToFields extends AddNewTripState {}

// ✅ الـ States الجديدة للكباتن
class SearchingNearestCaptainState extends AddNewTripState {}

class NearestCaptainFound extends AddNewTripState {
  final NearestCaptain captain;
  NearestCaptainFound(this.captain);
}

class NoCaptainAvailableState extends AddNewTripState {}
