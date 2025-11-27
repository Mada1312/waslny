import 'package:latlong2/latlong.dart';

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

class LocationUpdatedState extends LocationState {}

class ChangeLocationPermissionState extends LocationState {}

class RouteLoadingState extends LocationState {}

class RouteSuccessState extends LocationState {
  final num distance;
  final num duration;
  final List<LatLng> points;

  RouteSuccessState({
    required this.distance,
    required this.duration,
    required this.points,
  });
}

class RouteErrorState extends LocationState {}

class RouteClearedState extends LocationState {}

class LocationsResetState extends LocationState {}
