abstract class DriverHomeState {}

class DriverHomeInitial extends DriverHomeState {}
class DriverHomeLoading extends DriverHomeState {}
class DriverHomeLoaded extends DriverHomeState {}
class DriverHomeError extends DriverHomeState {}
class CompleteShipmentErrorState extends DriverHomeState {}
class CompleteShipmentSuccessState extends DriverHomeState {}
class CompleteShipmentLoadingState extends DriverHomeState {}
class CancelShipmentErrorState extends DriverHomeState {}
class CancelShipmentSuccessState extends DriverHomeState {}
class CancelShipmentLoadingState extends DriverHomeState {}
class BackgroundLocationUpdated extends DriverHomeState {}
class ChangeOnlineStatusState extends DriverHomeState {}
