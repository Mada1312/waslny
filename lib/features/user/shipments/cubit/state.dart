abstract class UserShipmentsState {}

class ShipmentsInitial extends UserShipmentsState {}

class ChangeShipmentsStatusState extends UserShipmentsState {}

class ChangeDriverState extends UserShipmentsState {}

class ChangeEnableNotificationsState extends UserShipmentsState {}

class ChangeRateValueState extends UserShipmentsState {}

class ShipmentDetailsLoadingState extends UserShipmentsState {}

class ShipmentDetailsLoadedState extends UserShipmentsState {}

class ShipmentDetailsErrorState extends UserShipmentsState {}

class AssignDriverLoadingState extends UserShipmentsState {}

class AssignDriverErrorState extends UserShipmentsState {}

class AssignDriverLoadedState extends UserShipmentsState {}

class ShipmentsLoadingState extends UserShipmentsState {}

class ShipmentsErrorState extends UserShipmentsState {}

class ShipmentsLoadedState extends UserShipmentsState {}

class AddRateForDriverErrorState extends UserShipmentsState {}

class AddRateForDriverSuccessState extends UserShipmentsState {}

class AddRateForDriverLoadingState extends UserShipmentsState {}

class ScreenshootState extends UserShipmentsState {}
