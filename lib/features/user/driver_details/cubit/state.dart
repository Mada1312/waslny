import '../data/model/driver_details_model.dart';

abstract class DriverDetailsState {}

class DriverDetailsInit extends DriverDetailsState {}

class DriverDetailsLoading extends DriverDetailsState {}

class DriverDetailsLoaded extends DriverDetailsState {
  final DriverDetailsModel? driver;
  DriverDetailsLoaded(this.driver);
}

class DriverDetailsError extends DriverDetailsState {
  final String message;

  DriverDetailsError(this.message);
}
