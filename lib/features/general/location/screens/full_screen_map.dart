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

class FullScreenMap extends StatefulWidget {
  const FullScreenMap({super.key, this.isTo = false});
  final bool? isTo;
  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap>
    with TickerProviderStateMixin {
  late final AnimatedMapController animatedMapController;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (context.read<LocationCubit>().selectedLocation == null) {
          context.read<LocationCubit>().checkAndRequestLocationPermission(
            context,
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
        if (widget.isTo == true) {
          context.read<AddNewTripCubit>().toAddressController.text =
              cubit.address;
          context.read<AddNewTripCubit>().toSelectedLocation =
              cubit.selectedLocation;
        } else {
          context.read<AddNewTripCubit>().fromAddressController.text =
              cubit.address;
          context.read<AddNewTripCubit>().fromSelectedLocation =
              cubit.selectedLocation;
        }

        Navigator.pop(context);
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "select_location".tr(),
              style: getBoldStyle(color: AppColors.black),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (widget.isTo == true) {
                  context.read<AddNewTripCubit>().toAddressController.text =
                      cubit.address;
                  context.read<AddNewTripCubit>().toSelectedLocation =
                      cubit.selectedLocation;
                } else {
                  context.read<AddNewTripCubit>().fromAddressController.text =
                      cubit.address;
                  context.read<AddNewTripCubit>().fromSelectedLocation =
                      cubit.selectedLocation;
                }
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
                      initialCenter: LatLng(
                        cubit.selectedLocation!.latitude ?? 0.0,
                        cubit.selectedLocation!.longitude ?? 0.0,
                      ),
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
                        print(
                          "Tapped LatLng: LatLng(latitude: $lat, longitude: $lng)",
                        );
                        cubit.updateSelectedPositionedCamera(
                          LatLng(lat, lng),
                          context,
                        );
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.octopus.waslny',
                      ),

                      MarkerLayer(markers: cubit.positionMarkers),
                      // Uncomment the following line if you want to add a custom marke
                    ],
                  ),
                  // ✅ Zoom Controls
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

                  // ✅ Current Location Button (Left side)
                  Positioned(
                    bottom: 24,
                    left: 16,
                    child: MapButton(
                      isCircular: true,
                      icon: Icons.my_location,
                      onTap: () => cubit.goToCurrentLocation(context),
                    ),
                  ),

                  // 🔍 Search box & suggestions
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
                              boxShadow: [
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
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  PositionedDirectional(
                    bottom: 10,
                    width: context.w,
                    child: Center(
                      child: SizedBox(
                        width: context.w / 2,
                        child: CustomButton(
                          padding: EdgeInsets.all(8),
                          onPressed: () {
                            if (widget.isTo == true) {
                              context
                                      .read<AddNewTripCubit>()
                                      .toAddressController
                                      .text =
                                  cubit.address;
                              context
                                      .read<AddNewTripCubit>()
                                      .toSelectedLocation =
                                  cubit.selectedLocation;
                            } else {
                              context
                                      .read<AddNewTripCubit>()
                                      .fromAddressController
                                      .text =
                                  cubit.address;
                              context
                                      .read<AddNewTripCubit>()
                                      .fromSelectedLocation =
                                  cubit.selectedLocation;
                            }
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
}

class MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isCircular;

  const MapButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shape: isCircular ? const CircleBorder() : const RoundedRectangleBorder(),
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
      ),
    );
  }
}
