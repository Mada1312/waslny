abstract class DriverHomeState {}

class DriverHomeInitial extends DriverHomeState {}

class DriverHomeLoading extends DriverHomeState {}

class DriverHomeLoaded extends DriverHomeState {}

class DriverHomeError extends DriverHomeState {}

class CompleteShipmentErrorState extends DriverHomeState {}

class CompleteShipmentSuccessState extends DriverHomeState {}

class CompleteShipmentLoadingState extends DriverHomeState {}

class UpdateTripStatusErrorState extends DriverHomeState {}

class UpdateTripStatusSuccessState extends DriverHomeState {}

class UpdateTripStatusLoadingState extends DriverHomeState {}

class BackgroundLocationUpdated extends DriverHomeState {}

class LoadingChangeOnlineStatusState extends DriverHomeState {}

class ErrorChangeOnlineStatusState extends DriverHomeState {}

class ChangeOnlineStatusState extends DriverHomeState {}

class ChangeSelectedIndexState extends DriverHomeState {}

class ImageFileUpdatedState extends DriverHomeState {}

class UploadDriverDataLoadingState extends DriverHomeState {}

class UploadDriverDataSuccessState extends DriverHomeState {}

class UploadDriverDataErrorState extends DriverHomeState {}
