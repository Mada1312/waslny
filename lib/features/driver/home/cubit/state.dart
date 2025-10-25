abstract class DriverHomeState {}

class DriverHomeInitial extends DriverHomeState {}

class DriverHomeLoading extends DriverHomeState {}

class DriverHomeLoaded extends DriverHomeState {}

class DriverHomeError extends DriverHomeState {}

class CompleteShipmentErrorState extends DriverHomeState {}

class CompleteShipmentSuccessState extends DriverHomeState {}

class CompleteShipmentLoadingState extends DriverHomeState {}

class CancelTripErrorState extends DriverHomeState {}

class CancelTripSuccessState extends DriverHomeState {}

class CancelTripLoadingState extends DriverHomeState {}

class BackgroundLocationUpdated extends DriverHomeState {}

class ChangeOnlineStatusState extends DriverHomeState {}

class ChangeSelectedIndexState extends DriverHomeState {}

class ImageFileUpdatedState extends DriverHomeState {}

class UploadDriverDataLoadingState extends DriverHomeState {}

class UploadDriverDataSuccessState extends DriverHomeState {}

class UploadDriverDataErrorState extends DriverHomeState {}
