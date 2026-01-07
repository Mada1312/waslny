import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:waslny/core/api/base_api_consumer.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/navigation/navigation_filters.dart';
import 'package:waslny/features/general/navigation/navigation_repo.dart';
import '../../../../injector.dart' as injector;

enum NavigationTargetMode { toDestination, toPickup }

class NavigationScreen extends StatefulWidget {
  final DriverTripModel currentTrip;
  final NavigationTargetMode mode;

  const NavigationScreen({
    super.key,
    required this.currentTrip,
    this.mode = NavigationTargetMode.toDestination,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  MapLibreMapController? _mapController;
  StreamSubscription<Position>? _sub;

  late final NavigationRepo _repo;
  final KalmanFilterLatLng _kalman = KalmanFilterLatLng(15.0);

  List<ll.LatLng> _route = [];
  bool _routeReady = false;

  double _speedKmh = 0;
  ll.LatLng _lastCameraTarget = const ll.LatLng(30.0444, 31.2357); // ✅ FIX

  // ✅ Route Bearing Controller
  late final RouteBearingController _bearingController;
  double _sCurrent = 0.0;
  double get _routeLengthMeters => _route.isEmpty ? 0.0 : _totalRouteDistance;

  // ✅ حساب إجمالي طول المسار
  double get _totalRouteDistance {
    if (_route.length < 2) return 0.0;
    const distance = ll.Distance();
    double total = 0.0;
    for (int i = 0; i < _route.length - 1; i++) {
      total += distance.as(ll.LengthUnit.Meter, _route[i], _route[i + 1]);
    }
    return total;
  }

  bool _isFetchingRoute = false;
  int _lastRerouteTime = 0;

  bool _showBottomPanel = false;

  late final ll.LatLng _destination;
  late final String _destinationName;

  static const String _styleUrl =
      'https://tiles.baraddy.com/styles/basic-preview/style.json';
  static const LatLng _fallback = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    _repo = NavigationRepo(injector.serviceLocator<BaseApiConsumer>());
    _bearingController = RouteBearingController();
    WakelockPlus.enable();

    // ✅ حدد الوجهة حسب mode
    final String? latStr = widget.mode == NavigationTargetMode.toPickup
        ? widget.currentTrip.fromLat
        : widget.currentTrip.toLat;

    final String? lngStr = widget.mode == NavigationTargetMode.toPickup
        ? widget.currentTrip.fromLong
        : widget.currentTrip.toLong;

    final String nameStr = widget.mode == NavigationTargetMode.toPickup
        ? (widget.currentTrip.from ?? "").trim()
        : ((widget.currentTrip.serviceToName ?? widget.currentTrip.to) ?? "")
              .trim();

    final toLat = double.tryParse(latStr ?? "");
    final toLng = double.tryParse(lngStr ?? "");

    if (toLat == null || toLng == null) {
      throw Exception(
        "Invalid lat/long in currentTrip => $latStr / $lngStr (mode=${widget.mode})",
      );
    }

    _destination = ll.LatLng(toLat, toLng);
    _destinationName = nameStr.isEmpty
        ? (widget.mode == NavigationTargetMode.toPickup
              ? "مكان العميل"
              : "الوجهة")
        : nameStr;
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _sub?.cancel();
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController c) async {
    _mapController = c;
    await _start();
  }

  Future<void> _start() async {
    await _ensurePermissions();

    Position? startPos;
    try {
      startPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
    } catch (e) {
      log("Error getting location: $e");
    }

    final startLat = startPos?.latitude ?? _fallback.latitude;
    final startLng = startPos?.longitude ?? _fallback.longitude;

    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(startLat, startLng),
          zoom: 17.0,
          tilt: 0.0,
          bearing: 0.0,
        ),
      ),
    );

    await _loadRoute(ll.LatLng(startLat, startLng), _destination);

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_onGps, onError: (e) => log("GPS stream error: $e"));
  }

  Future<void> _ensurePermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _loadRoute(ll.LatLng from, ll.LatLng to) async {
    if (_isFetchingRoute) return;
    _isFetchingRoute = true;

    try {
      final json = await _repo.getRoute(
        fromLat: from.latitude,
        fromLng: from.longitude,
        toLat: to.latitude,
        toLng: to.longitude,
      );

      final decoded = _extractRoutePolyline(json);

      if (decoded.isNotEmpty) {
        setState(() {
          _route = decoded;
          _routeReady = true;
        });
        await _drawRoute();
      }
    } catch (e) {
      log("Route API error: $e");
    } finally {
      _isFetchingRoute = false;
    }
  }

  List<ll.LatLng> _extractRoutePolyline(Map<String, dynamic> json) {
    dynamic coords = _deepGet(json, ["routes", 0, "geometry", "coordinates"]);
    coords ??= _deepGet(json, ["geometry", "coordinates"]);

    if (coords is List && coords.isNotEmpty) {
      try {
        return coords.map<ll.LatLng>((e) {
          return ll.LatLng((e[1] as num).toDouble(), (e[0] as num).toDouble());
        }).toList();
      } catch (_) {}
    }

    dynamic polyStr = _deepGet(json, ["routes", 0, "geometry"]);
    polyStr ??= _deepGet(json, ["geometry"]);

    if (polyStr is String && polyStr.isNotEmpty) {
      try {
        final pts = PolylinePoints.decodePolyline(polyStr);
        return pts.map((p) => ll.LatLng(p.latitude, p.longitude)).toList();
      } catch (_) {}
    }

    return [];
  }

  dynamic _deepGet(dynamic root, List<dynamic> path) {
    dynamic cur = root;
    for (final key in path) {
      if (cur == null) return null;
      if (key is int) {
        if (cur is List && cur.length > key) {
          cur = cur[key];
        } else {
          return null;
        }
      } else {
        if (cur is Map && cur.containsKey(key)) {
          cur = cur[key];
        } else {
          return null;
        }
      }
    }
    return cur;
  }

  Future<void> _drawRoute() async {
    if (_mapController == null || _route.isEmpty) return;

    await _mapController!.clearLines();
    await _mapController!.addLine(
      LineOptions(
        geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        lineColor: "#4285F4",
        lineWidth: 7.0,
        lineOpacity: 1.0,
        lineJoin: "round",
      ),
    );
  }

  /// ✅ دالة تحسب LatLng من مسافة s على المسار
  ll.LatLng latLngOnRouteFromS(double s) {
    if (_route.isEmpty) return _destination;

    const distance = ll.Distance();
    double accumulated = 0.0;

    for (int i = 0; i < _route.length - 1; i++) {
      final segmentDist = distance.as(
        ll.LengthUnit.Meter,
        _route[i],
        _route[i + 1],
      );

      if (accumulated + segmentDist >= s) {
        // النقطة على الـ segment ده
        final t = (s - accumulated) / segmentDist;
        return ll.LatLng(
          _route[i].latitude +
              t * (_route[i + 1].latitude - _route[i].latitude),
          _route[i].longitude +
              t * (_route[i + 1].longitude - _route[i].longitude),
        );
      }

      accumulated += segmentDist;
    }

    // لو s أكبر من طول المسار، ارجع آخر نقطة
    return _route.last;
  }

  void _onGps(Position raw) async {
    if (_mapController == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final filtered = _kalman.filter(
      lat: raw.latitude,
      lng: raw.longitude,
      accuracy: raw.accuracy,
      timestampMs: now,
    );

    // ✅ rerouting
    if (_routeReady && !_isFetchingRoute) {
      final distToRoute = _getMinDistanceToRoute(filtered, _route);
      if (distToRoute > 45.0 && (now - _lastRerouteTime > 5000)) {
        _lastRerouteTime = now;
        _loadRoute(filtered, _destination);
      }
    }

    ll.LatLng displayPos = filtered;
    if (_routeReady) {
      final snapped = RouteSnapper.snapToRoute(
        filtered,
        _route,
        maxSnapMeters: 40,
      );
      final dist = const ll.Distance().as(
        ll.LengthUnit.Meter,
        filtered,
        snapped,
      );
      if (dist < 40) {
        displayPos = snapped;
        // ✅ احسب المسافة على المسار
        _sCurrent = distanceAlongRoute(_route, displayPos);
      }
    }

    double instantSpeed = (raw.speed * 3.6);
    if (instantSpeed < 0) instantSpeed = 0;
    _speedKmh = (_speedKmh * 0.20) + (instantSpeed * 0.80);

    // ✅ استخدم Route Bearing بدل GPS heading
    double routeBearing = 0.0;
    if (_routeReady && _speedKmh > 3) {
      routeBearing = _bearingController.update(
        sCurrent: _sCurrent,
        routeLengthMeters: _routeLengthMeters,
        latLngOnRouteFromS: latLngOnRouteFromS,
        lookAheadMeters: 12.0,
        alpha: 0.15,
      );
    }

    const int animDuration = 1500;

    _lastCameraTarget = displayPos;

    double z = 17.0;
    if (_speedKmh > 80) {
      z = 15.0;
    } else if (_speedKmh > 40) {
      z = 16.0;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(displayPos.latitude, displayPos.longitude),
          bearing: routeBearing,
          zoom: z,
          tilt: 60.0,
        ),
      ),
      duration: Duration(milliseconds: animDuration),
    );

    if (mounted) setState(() {});
  }

  double _getMinDistanceToRoute(ll.LatLng p, List<ll.LatLng> poly) {
    if (poly.isEmpty) return 0.0;
    double minMeters = double.infinity;
    final ll.Distance distance = const ll.Distance();
    for (int i = 0; i < poly.length; i += 5) {
      final d = distance.as(ll.LengthUnit.Meter, p, poly[i]);
      if (d < minMeters) minMeters = d;
    }
    return minMeters;
  }

  Future<void> _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${_destination.latitude},${_destination.longitude}&travelmode=driving';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _finishTrip() async {
    final navLocal = Navigator.of(context);
    if (await navLocal.maybePop()) return;

    final navRoot = Navigator.of(context, rootNavigator: true);
    if (await navRoot.maybePop()) return;

    navLocal.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _styleUrl,
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _fallback,
              zoom: 15,
            ),
            myLocationEnabled: false,
            compassEnabled: false,
            attributionButtonPosition: AttributionButtonPosition.topRight,
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mode == NavigationTargetMode.toPickup
                        ? "مكان العميل:"
                        : "الوجهة:",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _destinationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _openGoogleMaps,
                      icon: const Icon(Icons.map_rounded, color: Colors.blue),
                      label: const Text(
                        "عرض في جوجل ماب",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.navigation_rounded,
                        size: 38,
                        color: Color(0xFF2E7DFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            right: 16,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${_speedKmh.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Text(
                    "كم/س",
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SwipeButton(
              child: const Text(
                "اسحب لإنهاء الرحلة",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onSwipe: () async => _finishTrip(),
              activeThumbColor: Colors.green,
              activeTrackColor: Colors.green.withOpacity(0.3),
              thumb: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "إنهاء",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              height: 70,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
