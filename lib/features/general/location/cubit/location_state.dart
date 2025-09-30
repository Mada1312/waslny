abstract class LocationState {}

class LocationInitial extends LocationState {}

class GetCurrentLocationState extends LocationState {}

class DisposeMapState extends LocationState {}

class GetCurrentLocationAddressState extends LocationState {}

class ErrorCurrentLocationAddressState extends LocationState {}

class SetPositionMarkerState extends LocationState {}

class SetSelectedLocationState extends LocationState {}

class ChangeValueState extends LocationState {}

class GetServicesLoadingState extends LocationState {}

class GetServicesErrorState extends LocationState {}

class GetServicesSuccessState extends LocationState {}

class SetMarkersState extends LocationState {}

class SetCircleState extends LocationState {}
class SetMapZoomState extends LocationState {}
class GetAddressMapSuccessState extends LocationState {}
class GetAddressMapLoadingState extends LocationState {}
class GetAddressMapErrorState extends LocationState {}
