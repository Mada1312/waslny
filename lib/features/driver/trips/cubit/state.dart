abstract class DriverTripsState {}

class DriverTripsInitial extends DriverTripsState {}

class ChangeShipmentsStatusState extends DriverTripsState {}

class ChangeDriverState extends DriverTripsState {}

class ChangeEnableNotificationsState extends DriverTripsState {}

class ChangeRateValueState extends DriverTripsState {}

class GetShipmentDetailsLoadingState extends DriverTripsState {}

class GetShipmentDetailsSuccessState extends DriverTripsState {}

class GetShipmentDetailsErrorState extends DriverTripsState {}

class RequestShipmentLoadingState extends DriverTripsState {}

class RequestShipmentSuccessState extends DriverTripsState {}

class RequestShipmentErrorState extends DriverTripsState {}

class GetShipmentsLoadingState extends DriverTripsState {}

class GetShipmentsErrorState extends DriverTripsState {}

class GetShipmentsSuccessState extends DriverTripsState {}

class AddRateForUserErrorState extends DriverTripsState {}

class AddRateForUserSuccessState extends DriverTripsState {}

class AddRateForUserLoadingState extends DriverTripsState {}
