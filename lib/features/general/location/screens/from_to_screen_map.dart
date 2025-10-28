import 'package:waslny/extention.dart';
import 'package:waslny/features/user/add_new_trip/cubit/cubit.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:waslny/core/exports.dart';
import 'package:latlong2/latlong.dart';
import 'package:waslny/core/utils/convert_numbers_method.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import 'widgets/map_button.dart';

class FromToScreenMap extends StatefulWidget {
  const FromToScreenMap({super.key, required this.isTo});

  final bool isTo;

  @override
  State<FromToScreenMap> createState() => _FromToScreenMapState();
}

class _FromToScreenMapState extends State<FromToScreenMap>
    with TickerProviderStateMixin {
  late final AnimatedMapController animatedMapController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<LocationCubit>();

        if (cubit.selectedLocation == null) {
          cubit.checkAndRequestLocationPermission(context);
        }

        // Initialize from and to locations from AddNewTripCubit
        final tripCubit = context.read<AddNewTripCubit>();

        if (tripCubit.fromSelectedLocation != null) {
          cubit.setFromLocation(
            LatLng(
              tripCubit.fromSelectedLocation!.latitude ?? 0.0,
              tripCubit.fromSelectedLocation!.longitude ?? 0.0,
            ),
          );
        }

        if (tripCubit.toSelectedLocation != null) {
          cubit.setToLocation(
            LatLng(
              tripCubit.toSelectedLocation!.latitude ?? 0.0,
              tripCubit.toSelectedLocation!.longitude ?? 0.0,
            ),
          );
        }
      }
    });

    animatedMapController = AnimatedMapController(vsync: this);
    context.read<LocationCubit>().setAnimatedMapController(
      animatedMapController,
    );
    context.read<LocationCubit>().placeSuggestions.clear();
  }

  @override
  Widget build(BuildContext context) {
    final LocationCubit cubit = context.read<LocationCubit>();

    return WillPopScope(
      onWillPop: () {
        _saveLocationToTrip(cubit);
        Navigator.pop(context);
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isTo
                  ? "select_to_location".tr()
                  : "select_from_location".tr(),
              style: getBoldStyle(color: AppColors.black),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _saveLocationToTrip(cubit);
                Navigator.pop(context);
              },
            ),
          ),
          body: BlocBuilder<LocationCubit, LocationState>(
            builder: (context, state) {
              if (!cubit.isPermissionChecked) {
                return const Center(
                  child: CustomLoadingIndicator(withLogo: false),
                );
              }
              if (!cubit.isPermissionGranted) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "location_describtion".tr(),
                        textAlign: TextAlign.center,
                        style: getRegularStyle(
                          fontSize: 12.sp,
                          fontHeight: 1.2,
                        ),
                      ),
                      16.verticalSpace,
                      CustomButton(
                        title: "open_settings".tr(),
                        onPressed: () async => perm.openAppSettings(),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  FlutterMap(
                    mapController: animatedMapController.mapController,
                    options: MapOptions(
                      initialZoom: 12,
                      initialCenter: _getInitialCenter(cubit),
                      onTap: (tapPosition, tappedLatLng) {
                        double lat = double.parse(
                          (replaceToEnglishNumber(
                            tappedLatLng.latitude.toString(),
                          )),
                        );
                        double lng = double.parse(
                          (replaceToEnglishNumber(
                            tappedLatLng.longitude.toString(),
                          )),
                        );

                        LatLng newLatLng = LatLng(lat, lng);
                        cubit.updateSelectedPositionedCamera(
                          newLatLng,
                          context,
                        );

                        // Update from or to based on isTo flag
                        if (widget.isTo) {
                          cubit.updateToLocation(newLatLng);
                        } else {
                          cubit.updateFromLocation(newLatLng);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.octopus.waslny',
                      ),

                      // Route polyline
                      if (cubit.routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: cubit.routePoints,
                              strokeWidth: 4.0,
                              color: AppColors.primary,
                            ),
                          ],
                        ),

                      // Markers
                      MarkerLayer(markers: _buildMarkers(cubit)),
                    ],
                  ),

                  // Loading indicator for route
                  if (cubit.isLoadingRoute)
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(blurRadius: 4, color: Colors.black26),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text("calculating_route".tr()),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Distance and duration info
                  if (cubit.routeDistance > 0 && !cubit.isLoadingRoute)
                    Positioned(
                      top: 80,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(blurRadius: 4, color: Colors.black26),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cubit.getFormattedDistance(),
                                  style: getBoldStyle(color: AppColors.black),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cubit.getFormattedDuration(),
                                  style: getBoldStyle(color: AppColors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Zoom Controls
                  Positioned(
                    bottom: 24,
                    right: 16,
                    child: Column(
                      children: [
                        MapButton(
                          icon: Icons.add,
                          onTap: () {
                            final currentZoom =
                                animatedMapController.mapController.camera.zoom;
                            animatedMapController.animateTo(
                              zoom: currentZoom + 1,
                              dest: animatedMapController
                                  .mapController
                                  .camera
                                  .center,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        MapButton(
                          icon: Icons.remove,
                          onTap: () {
                            final currentZoom =
                                animatedMapController.mapController.camera.zoom;
                            animatedMapController.animateTo(
                              zoom: currentZoom - 1,
                              dest: animatedMapController
                                  .mapController
                                  .camera
                                  .center,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Current Location Button
                  Positioned(
                    bottom: 24,
                    left: 16,
                    child: MapButton(
                      isCircular: true,
                      icon: Icons.my_location,
                      onTap: () => cubit.goToCurrentLocation(context),
                    ),
                  ),

                  // Search box & suggestions
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _searchController,
                          backgroundColor: Colors.white,
                          onChanged: (value) {
                            EasyDebounce.debounce(
                              'searchOnMap',
                              const Duration(seconds: 1),
                              () async => await cubit.searchOnMap(
                                _searchController.text,
                              ),
                            );
                          },
                          prefixIcon: const Icon(Icons.search),
                          hintText: "search_location".tr(),
                        ),
                        if (cubit.placeSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(blurRadius: 4, color: Colors.black12),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: cubit.placeSuggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion =
                                    cubit.placeSuggestions[index];
                                return ListTile(
                                  title: Text(suggestion.displayName ?? ''),
                                  onTap: () {
                                    _searchController.clear();
                                    cubit.selectPlaceSuggestion(
                                      suggestion.placeId ?? 0,
                                      context,
                                    );

                                    // Update location after selection
                                    if (cubit.selectedLocation != null) {
                                      LatLng newLatLng = LatLng(
                                        cubit.selectedLocation!.latitude ?? 0.0,
                                        cubit.selectedLocation!.longitude ??
                                            0.0,
                                      );

                                      if (widget.isTo) {
                                        cubit.updateToLocation(newLatLng);
                                      } else {
                                        cubit.updateFromLocation(newLatLng);
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Confirm button
                  PositionedDirectional(
                    bottom: 10,
                    width: context.w,
                    child: Center(
                      child: SizedBox(
                        width: context.w / 2,
                        child: CustomButton(
                          padding: const EdgeInsets.all(8),
                          onPressed: () {
                            _saveLocationToTrip(cubit);
                            Navigator.pop(context);
                          },
                          title: 'confirm_destination'.tr(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  LatLng _getInitialCenter(LocationCubit cubit) {
    if (widget.isTo && cubit.toLocation != null) {
      return cubit.toLocation!;
    } else if (!widget.isTo && cubit.fromLocation != null) {
      return cubit.fromLocation!;
    } else if (cubit.selectedLocation != null) {
      return LatLng(
        cubit.selectedLocation!.latitude ?? 0.0,
        cubit.selectedLocation!.longitude ?? 0.0,
      );
    }
    return const LatLng(0.0, 0.0);
  }

  List<Marker> _buildMarkers(LocationCubit cubit) {
    List<Marker> markers = [];

    // From marker (blue)
    if (cubit.fromLocation != null) {
      markers.add(
        Marker(
          point: cubit.fromLocation!,
          child: MySvgWidget(
            path: AppIcons.pin,
            width: 50,
            height: 50,
            imageColor: Colors.blue,
          ),
        ),
      );
    }

    // To marker (red)
    if (cubit.toLocation != null) {
      markers.add(
        Marker(
          point: cubit.toLocation!,
          child: MySvgWidget(
            path: AppIcons.pin,
            width: 50,
            height: 50,
            imageColor: Colors.red,
          ),
        ),
      );
    }

    // Current selection marker (only if different from from/to)
    if (cubit.positionMarkers.isNotEmpty) {
      final selectedPoint = cubit.positionMarkers.first.point;
      final isDifferentFromFromTo =
          (cubit.fromLocation == null || selectedPoint != cubit.fromLocation) &&
          (cubit.toLocation == null || selectedPoint != cubit.toLocation);

      if (isDifferentFromFromTo) {
        markers.addAll(cubit.positionMarkers);
      }
    }

    return markers;
  }

  void _saveLocationToTrip(LocationCubit cubit) {
    if (widget.isTo) {
      context.read<AddNewTripCubit>().toAddressController.text = cubit.address;
      context.read<AddNewTripCubit>().toSelectedLocation =
          cubit.selectedLocation;
    } else {
      context.read<AddNewTripCubit>().fromAddressController.text =
          cubit.address;
      context.read<AddNewTripCubit>().fromSelectedLocation =
          cubit.selectedLocation;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
