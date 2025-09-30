abstract class DriverShipmentsState {}

class DriverShipmentsInitial extends DriverShipmentsState {}

class ChangeShipmentsStatusState extends DriverShipmentsState {}

class ChangeDriverState extends DriverShipmentsState {}

class ChangeEnableNotificationsState extends DriverShipmentsState {}

class ChangeRateValueState extends DriverShipmentsState {}

class GetShipmentDetailsLoadingState extends DriverShipmentsState {}

class GetShipmentDetailsSuccessState extends DriverShipmentsState {}

class GetShipmentDetailsErrorState extends DriverShipmentsState {}

class RequestShipmentLoadingState extends DriverShipmentsState {}

class RequestShipmentSuccessState extends DriverShipmentsState {}

class RequestShipmentErrorState extends DriverShipmentsState {}

class GetShipmentsLoadingState extends DriverShipmentsState {}

class GetShipmentsErrorState extends DriverShipmentsState {}

class GetShipmentsSuccessState extends DriverShipmentsState {}

class AddRateForUserErrorState extends DriverShipmentsState {}

class AddRateForUserSuccessState extends DriverShipmentsState {}

class AddRateForUserLoadingState extends DriverShipmentsState {}
