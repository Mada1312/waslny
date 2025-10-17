// ignore_for_file: use_build_context_synchronously

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

  // GoogleMapController? mapController;
  // GoogleMapController? positionMapController;
  // MapController positionMapController = MapController();
  MapController mapController = MapController();

  String address = "";

  bool isPermissionChecked = false;
  bool isPermissionGranted = false;

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
        // emit(GetCurrentLocationState());
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
    // positionMapController.move(
    //   latLng,
    //   positionMapController.camera.zoom,
    // );

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

  // Future<void> _getAddressFromLatLng(double latitude, double longitude) async {

  //   try {
  //     final List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude);
  //     if (placemarks.isNotEmpty) {
  //       final Placemark place = placemarks.first;
  //       // country = place.country ?? "";

  //      String address2 =
  //           "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}, ${place.administrativeArea}, ${place.name}, ${place.subLocality}, ${place.subThoroughfare}";
  //       address = "${place.locality}, ${place.administrativeArea}";
  //       emit(GetCurrentLocationAddressState());
  //     } else {
  //       emit(ErrorCurrentLocationAddressState());
  //     }
  //   } catch (e) {
  //     debugPrint("Error: ${e.toString()}");
  //     emit(ErrorCurrentLocationAddressState());
  //   }
  // }

  _getAddressFromLatLng(lat, long) async {
    emit(GetAddressMapLoadingState());
    final response = await api.getAddressMap(lat: lat, long: long);
    response.fold((failure) => emit(GetAddressMapErrorState()), (data) {
      address = data.displayName ?? "";
      // address = "${data.address?.city??""}, ${data.address?.state??""}";
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

    if (latLng != null) {
      placeSuggestions.clear();
      updateSelectedPositionedCamera(latLng, context);
      // mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    }
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

  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }
}
