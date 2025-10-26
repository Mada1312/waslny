import '../data/model/driver_details_model.dart';

abstract class DriverProfileState {}

class DriverProfileInit extends DriverProfileState {}

class DriverDetailsLoading extends DriverProfileState {}

class DriverDetailsLoaded extends DriverProfileState {
  final DriverProfileMainModel? driver;
  DriverDetailsLoaded(this.driver);
}

class DriverDetailsError extends DriverProfileState {
  final String message;

  DriverDetailsError(this.message);
}
