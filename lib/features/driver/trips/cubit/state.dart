abstract class DriverTripsState {}

class DriverTripsInitial extends DriverTripsState {}

class ChangeDriverState extends DriverTripsState {}

class ChangeEnableNotificationsState extends DriverTripsState {}

class ChangeRateValueState extends DriverTripsState {}

class GetTripDetailsLoadingState extends DriverTripsState {}

class GetTripDetailsSuccessState extends DriverTripsState {}

class GetTripDetailsErrorState extends DriverTripsState {}

class RequestShipmentLoadingState extends DriverTripsState {}

class RequestShipmentSuccessState extends DriverTripsState {}

class RequestShipmentErrorState extends DriverTripsState {}

class GetTripsLoadingState extends DriverTripsState {}

class GetTripsErrorState extends DriverTripsState {}

class GetTripsSuccessState extends DriverTripsState {}

class AddRateForUserErrorState extends DriverTripsState {}

class AddRateForUserSuccessState extends DriverTripsState {}

class AddRateForUserLoadingState extends DriverTripsState {}
