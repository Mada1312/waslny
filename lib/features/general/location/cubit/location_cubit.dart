// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:developer';
// import 'dart:ui' as ui;

// import 'package:waslny/core/utils/convert_numbers_method.dart';
// import 'package:waslny/features/general/location/data/models/get_address_map_model.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_animations/flutter_map_animations.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart' as loc;
// import 'package:waslny/core/exports.dart';
// import 'package:permission_handler/permission_handler.dart' as perm;
// import 'package:latlong2/latlong.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../data/repo.dart';
// import 'location_state.dart';

// class LocationCubit extends Cubit<LocationState> {
//   LocationCubit(this.api) : super(LocationInitial());

//   LocationRepo api;
//   StreamSubscription<Position>? _positionStream;
//   loc.LocationData? currentLocation;
//   bool isFirstTime = true;
//   loc.LocationData? selectedLocation;
//   List<Marker> positionMarkers = [];
//   Uint8List? markerIcon;

//   // GoogleMapController? mapController;
//   // GoogleMapController? positionMapController;
//   // MapController positionMapController = MapController();
//   MapController mapController = MapController();

//   String address = "";

//   bool isPermissionChecked = false;
//   bool isPermissionGranted = false;

//   Future<void> checkAndRequestLocationPermission(BuildContext context) async {
//     final permissionStatus = await perm.Permission.location.status;

//     if (permissionStatus.isDenied) {
//       final newStatus = await perm.Permission.location.request();
//       if (newStatus.isGranted) {
//         isPermissionGranted = true;
//         await _enableLocationServices(context);
//       } else if (newStatus.isPermanentlyDenied) {
//         _showLocationPermissionDialog(context);
//       }
//     } else if (permissionStatus.isGranted) {
//       isPermissionGranted = true;
//       await _enableLocationServices(context);
//     } else if (permissionStatus.isPermanentlyDenied) {
//       _showLocationPermissionDialog(context);
//     }

//     isPermissionChecked = true;
//     emit(LocationInitial());
//   }

//   Future<void> _enableLocationServices(BuildContext context) async {
//     final location = loc.Location();
//     bool serviceEnabled = await location.serviceEnabled();

//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) return;
//     }

//     final permissionStatus = await location.hasPermission();
//     if (permissionStatus == loc.PermissionStatus.granted) {
//       await _getCurrentLocation(context);
//     }
//   }

//   Future<void> _getCurrentLocation(BuildContext context) async {
//     final location = loc.Location();
//     location.getLocation().then((location) async {
//       currentLocation = location;
//       if (isFirstTime && selectedLocation == null) {
//         selectedLocation = location;
//       }
//       isFirstTime = false;

//       await _getAddressFromLatLng(
//         location.latitude ?? 0.0,
//         location.longitude ?? 0.0,
//       );
//       _setPositionMarker();

//       emit(GetCurrentLocationState());
//     });

//     location.onLocationChanged.listen((newLocationData) async {
//       if (currentLocation != null) {
//         final distance = Geolocator.distanceBetween(
//           currentLocation!.latitude ?? 0.0,
//           currentLocation!.longitude ?? 0.0,
//           newLocationData.latitude ?? 0.0,
//           newLocationData.longitude ?? 0.0,
//         );

//         if (distance > 8) {
//           currentLocation = newLocationData;
//         }
//         // emit(GetCurrentLocationState());
//       }
//     });
//   }

//   void _setPositionMarker() {
//     positionMarkers = [
//       Marker(
//         point: LatLng(
//           selectedLocation?.latitude ?? currentLocation?.latitude ?? 0.0,
//           selectedLocation?.longitude ?? currentLocation?.longitude ?? 0.0,
//         ),
//         child: buildMarker(),
//       ),
//     ];
//     emit(SetPositionMarkerState());
//   }

//   MySvgWidget buildMarker() {
//     return MySvgWidget(
//       path: AppIcons.pin,
//       width: 50,
//       height: 50,
//       imageColor: AppColors.primary,
//     );
//   }

//   late AnimatedMapController animatedMapController;

//   void setAnimatedMapController(AnimatedMapController controller) {
//     animatedMapController = controller;
//   }

//   Future<void> updateSelectedPositionedCamera(
//     LatLng latLng,
//     BuildContext context,
//   ) async {
//     animatedMapController.animateTo(
//       dest: latLng,
//       zoom: animatedMapController.mapController.camera.zoom,
//       rotation: 0,
//       curve: Curves.easeInOut,
//       duration: const Duration(milliseconds: 600),
//     );
//     // positionMapController.move(
//     //   latLng,
//     //   positionMapController.camera.zoom,
//     // );

//     _setSelectedPositionedLocation(latLng, context);
//   }

//   void _setSelectedPositionedLocation(LatLng latLng, BuildContext? context) {
//     selectedLocation = loc.LocationData.fromMap({
//       "latitude": latLng.latitude,
//       "longitude": latLng.longitude,
//     });
//     _getAddressFromLatLng(latLng.latitude, latLng.longitude);
//     _setPositionMarker();
//     emit(SetSelectedLocationState());
//   }

//   void setSelectedPositionedLocationToDefault() {
//     selectedLocation = loc.LocationData.fromMap({
//       "latitude": currentLocation?.latitude ?? 0.0,
//       "longitude": currentLocation?.longitude ?? 0.0,
//     });
//     _getAddressFromLatLng(
//       selectedLocation!.latitude ?? 0.0,
//       selectedLocation!.longitude ?? 0.0,
//     );
//     _setPositionMarker();
//     emit(SetSelectedLocationState());
//   }


//   _getAddressFromLatLng(lat, long) async {
//     emit(GetAddressMapLoadingState());
//     final response = await api.getAddressMap(lat: lat, long: long);
//     response.fold((failure) => emit(GetAddressMapErrorState()), (data) {
//       address = data.displayName ?? "";
//       // address = "${data.address?.city??""}, ${data.address?.state??""}";
//       log("Address: $address");
//       emit(GetAddressMapSuccessState());
//     });
//   }

//   List<GetAddressMapModel> placeSuggestions = [];

//   Future<void> selectPlaceSuggestion(int placeId, BuildContext context) async {
//     final latLng = LatLng(
//       double.parse(
//         replaceToEnglishNumber(
//           placeSuggestions
//               .firstWhere((element) => element.placeId == placeId)
//               .lat
//               .toString(),
//         ),
//       ),
//       double.parse(
//         replaceToEnglishNumber(
//           placeSuggestions
//               .firstWhere((element) => element.placeId == placeId)
//               .lon
//               .toString(),
//         ),
//       ),
//     );

//     if (latLng != null) {
//       placeSuggestions.clear();
//       updateSelectedPositionedCamera(latLng, context);
//       // mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
//     }
//   }

//   Future<void> goToCurrentLocation(BuildContext context) async {
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       final currentLatLng = LatLng(position.latitude, position.longitude);

//       updateSelectedPositionedCamera(currentLatLng, context);
//     } catch (e) {
//       print("Failed to get current location: $e");
//     }
//   }

//   searchOnMap(String lat) async {
//     emit(GetAddressMapLoadingState());
//     final response = await api.searchOnMap(searchKey: lat);
//     response.fold((failure) => emit(GetAddressMapErrorState()), (data) {
//       placeSuggestions = data;

//       emit(GetAddressMapSuccessState());
//     });
//   }

//   void _showLocationPermissionDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("location_required".tr()),
//         content: Text("location_describtion".tr()),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("cancel".tr()),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await perm.openAppSettings();
//             },
//             child: Text("open_settings".tr()),
//           ),
//         ],
//       ),
//     );
//   }

//   void openGoogleMapsRoute(double destinationLat, double destinationLng) async {
//     final url =
//         'https://www.google.com/maps/dir/?api=1&origin=${currentLocation?.latitude},${currentLocation?.longitude}&destination=$destinationLat,$destinationLng';

//     try {
//       launchUrl(Uri.parse(url));
//     } catch (e) {
//       errorGetBar("error from map");
//     }
//   }

//   @override
//   Future<void> close() {
//     _positionStream?.cancel();
//     return super.close();
//   }
// }



//////// OSRM /////////////
///// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:waslny/core/utils/convert_numbers_method.dart';
import 'package:waslny/features/general/location/data/models/get_address_map_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:waslny/core/exports.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:osrm/osrm.dart';

import '../data/repo.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this.api) : super(LocationInitial());

  LocationRepo api;
  StreamSubscription<Position>? _positionStream;
  loc.LocationData? currentLocation;
  bool isFirstTime = true;
  loc.LocationData? selectedLocation;
  List<Marker> positionMarkers = [];
  Uint8List? markerIcon;

  MapController mapController = MapController();

  String address = "";

  bool isPermissionChecked = false;
  bool isPermissionGranted = false;

  // ============ OSRM Route Properties ============
  List<LatLng> routePoints = [];
  num routeDistance = 0.0;
  num routeDuration = 0.0;
  bool isLoadingRoute = false;
  
  LatLng? fromLocation;
  LatLng? toLocation;
  // ===============================================

  Future<void> checkAndRequestLocationPermission(BuildContext context) async {
    final permissionStatus = await perm.Permission.location.status;

    if (permissionStatus.isDenied) {
      final newStatus = await perm.Permission.location.request();
      if (newStatus.isGranted) {
        isPermissionGranted = true;
        await _enableLocationServices(context);
      } else if (newStatus.isPermanentlyDenied) {
        _showLocationPermissionDialog(context);
      }
    } else if (permissionStatus.isGranted) {
      isPermissionGranted = true;
      await _enableLocationServices(context);
    } else if (permissionStatus.isPermanentlyDenied) {
      _showLocationPermissionDialog(context);
    }

    isPermissionChecked = true;
    emit(LocationInitial());
  }

  Future<void> _enableLocationServices(BuildContext context) async {
    final location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    final permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.granted) {
      await _getCurrentLocation(context);
    }
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    final location = loc.Location();
    location.getLocation().then((location) async {
      currentLocation = location;
      if (isFirstTime && selectedLocation == null) {
        selectedLocation = location;
      }
      isFirstTime = false;

      await _getAddressFromLatLng(
        location.latitude ?? 0.0,
        location.longitude ?? 0.0,
      );
      _setPositionMarker();

      emit(GetCurrentLocationState());
    });

    location.onLocationChanged.listen((newLocationData) async {
      if (currentLocation != null) {
        final distance = Geolocator.distanceBetween(
          currentLocation!.latitude ?? 0.0,
          currentLocation!.longitude ?? 0.0,
          newLocationData.latitude ?? 0.0,
          newLocationData.longitude ?? 0.0,
        );

        if (distance > 8) {
          currentLocation = newLocationData;
        }
      }
    });
  }

  void _setPositionMarker() {
    positionMarkers = [
      Marker(
        point: LatLng(
          selectedLocation?.latitude ?? currentLocation?.latitude ?? 0.0,
          selectedLocation?.longitude ?? currentLocation?.longitude ?? 0.0,
        ),
        child: buildMarker(),
      ),
    ];
    emit(SetPositionMarkerState());
  }

  MySvgWidget buildMarker() {
    return MySvgWidget(
      path: AppIcons.pin,
      width: 50,
      height: 50,
      imageColor: AppColors.primary,
    );
  }

  late AnimatedMapController animatedMapController;

  void setAnimatedMapController(AnimatedMapController controller) {
    animatedMapController = controller;
  }

  Future<void> updateSelectedPositionedCamera(
    LatLng latLng,
    BuildContext context,
  ) async {
    animatedMapController.animateTo(
      dest: latLng,
      zoom: animatedMapController.mapController.camera.zoom,
      rotation: 0,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 600),
    );

    _setSelectedPositionedLocation(latLng, context);
  }

  void _setSelectedPositionedLocation(LatLng latLng, BuildContext? context) {
    selectedLocation = loc.LocationData.fromMap({
      "latitude": latLng.latitude,
      "longitude": latLng.longitude,
    });
    _getAddressFromLatLng(latLng.latitude, latLng.longitude);
    _setPositionMarker();
    emit(SetSelectedLocationState());
  }

  void setSelectedPositionedLocationToDefault() {
    selectedLocation = loc.LocationData.fromMap({
      "latitude": currentLocation?.latitude ?? 0.0,
      "longitude": currentLocation?.longitude ?? 0.0,
    });
    _getAddressFromLatLng(
      selectedLocation!.latitude ?? 0.0,
      selectedLocation!.longitude ?? 0.0,
    );
    _setPositionMarker();
    emit(SetSelectedLocationState());
  }

  _getAddressFromLatLng(lat, long) async {
    emit(GetAddressMapLoadingState());
    final response = await api.getAddressMap(lat: lat, long: long);
    response.fold((failure) => emit(GetAddressMapErrorState()), (data) {
      address = data.displayName ?? "";
      log("Address: $address");
      emit(GetAddressMapSuccessState());
    });
  }

  List<GetAddressMapModel> placeSuggestions = [];

  Future<void> selectPlaceSuggestion(int placeId, BuildContext context) async {
    final latLng = LatLng(
      double.parse(
        replaceToEnglishNumber(
          placeSuggestions
              .firstWhere((element) => element.placeId == placeId)
              .lat
              .toString(),
        ),
      ),
      double.parse(
        replaceToEnglishNumber(
          placeSuggestions
              .firstWhere((element) => element.placeId == placeId)
              .lon
              .toString(),
        ),
      ),
    );

    placeSuggestions.clear();
    updateSelectedPositionedCamera(latLng, context);
  }

  Future<void> goToCurrentLocation(BuildContext context) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      updateSelectedPositionedCamera(currentLatLng, context);
    } catch (e) {
      print("Failed to get current location: $e");
    }
  }

  searchOnMap(String lat) async {
    emit(GetAddressMapLoadingState());
    final response = await api.searchOnMap(searchKey: lat);
    response.fold((failure) => emit(GetAddressMapErrorState()), (data) {
      placeSuggestions = data;

      emit(GetAddressMapSuccessState());
    });
  }

  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("location_required".tr()),
        content: Text("location_describtion".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await perm.openAppSettings();
            },
            child: Text("open_settings".tr()),
          ),
        ],
      ),
    );
  }

  void openGoogleMapsRoute(double destinationLat, double destinationLng) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${currentLocation?.latitude},${currentLocation?.longitude}&destination=$destinationLat,$destinationLng';

    try {
      launchUrl(Uri.parse(url));
    } catch (e) {
      errorGetBar("error from map");
    }
  }

  // ============ OSRM Route Methods ============

  /// Get route between two locations using OSRM
  Future<void> getRouteBetweenLocations(
    LatLng from,
    LatLng to,
  ) async {
    isLoadingRoute = true;
    emit(RouteLoadingState());

    try {
      final osrm = Osrm();
      
      final options = RouteRequest(
        coordinates: [
          (from.longitude, from.latitude),
          (to.longitude, to.latitude),
        ],
        overview: OsrmOverview.full,
      );
      
      final route = await osrm.route(options);
      
      if (route.routes.isNotEmpty) {
        routeDistance = route.routes.first.distance ?? 0.0;
        routeDuration = route.routes.first.duration ?? 0.0;
        routePoints = route.routes.first.geometry?.lineString?.coordinates
            .map((e) {
          var location = e.toLocation();
          return LatLng(location.lat, location.lng);
        }).toList() ?? [];
        
        log("Route calculated: ${getFormattedDistance()}, ${getFormattedDuration()}");
        
        isLoadingRoute = false;
        emit(RouteSuccessState(
          distance: routeDistance,
          duration: routeDuration,
          points: routePoints,
        ));
      } else {
        isLoadingRoute = false;
        emit(RouteErrorState());
      }
    } catch (e) {
      log("Error getting route: $e");
      isLoadingRoute = false;
      emit(RouteErrorState());
    }
  }

  /// Set from location
  void setFromLocation(LatLng location) {
    fromLocation = location;
    emit(LocationUpdatedState());
  }

  /// Set to location
  void setToLocation(LatLng location) {
    toLocation = location;
    emit(LocationUpdatedState());
  }

  /// Update from location and recalculate route
  void updateFromLocation(LatLng location) {
    fromLocation = location;
    if (toLocation != null) {
      getRouteBetweenLocations(fromLocation!, toLocation!);
    }
    emit(LocationUpdatedState());
  }

  /// Update to location and recalculate route
  void updateToLocation(LatLng location) {
    toLocation = location;
    if (fromLocation != null) {
      getRouteBetweenLocations(fromLocation!, toLocation!);
    }
    emit(LocationUpdatedState());
  }

  /// Clear route data
  void clearRoute() {
    routePoints.clear();
    routeDistance = 0.0;
    routeDuration = 0.0;
    isLoadingRoute = false;
    emit(RouteClearedState());
  }

  /// Reset from and to locations
  void resetFromToLocations() {
    fromLocation = null;
    toLocation = null;
    clearRoute();
    emit(LocationsResetState());
  }

  /// Get formatted distance string
  String getFormattedDistance() {
    if (routeDistance == 0) return "0 km";
    if (routeDistance < 1000) {
      return "${routeDistance.toStringAsFixed(0)} m";
    }
    return "${(routeDistance / 1000).toStringAsFixed(2)} km";
  }

  /// Get formatted duration string
  String getFormattedDuration() {
    if (routeDuration == 0) return "0 min";
    final minutes = (routeDuration / 60).floor();
    if (minutes < 60) {
      return "$minutes min";
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return "${hours}h ${remainingMinutes}min";
    }
  }

  /// Animate camera to show full route
  void animateCameraToShowRoute() {
    if (routePoints.isEmpty) return;

    // Calculate bounds
    double minLat = routePoints.first.latitude;
    double maxLat = routePoints.first.latitude;
    double minLng = routePoints.first.longitude;
    double maxLng = routePoints.first.longitude;

    for (var point in routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    // Calculate appropriate zoom level
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    // Rough zoom level calculation
    double zoom = 12;
    if (maxDiff > 0.5) {
      zoom = 8;
    } else if (maxDiff > 0.1) {
      zoom = 10;
    } else if (maxDiff > 0.05) {
      zoom = 12;
    } else {
      zoom = 14;
    }

    animatedMapController.animateTo(
      dest: LatLng(centerLat, centerLng),
      zoom: zoom,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  /// Get route distance in meters
  num getRouteDistanceInMeters() {
    return routeDistance;
  }

  /// Get route distance in kilometers
  double getRouteDistanceInKilometers() {
    return routeDistance / 1000;
  }

  /// Get route duration in seconds
  num getRouteDurationInSeconds() {
    return routeDuration;
  }

  /// Get route duration in minutes
  int getRouteDurationInMinutes() {
    return (routeDuration / 60).floor();
  }

  /// Check if route exists
  bool hasRoute() {
    return routePoints.isNotEmpty && routeDistance > 0;
  }

  /// Check if both from and to locations are set
  bool hasFromAndToLocations() {
    return fromLocation != null && toLocation != null;
  }

  // ============================================

  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }
}