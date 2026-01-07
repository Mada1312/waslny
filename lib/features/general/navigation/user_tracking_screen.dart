import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:waslny/core/api/base_api_consumer.dart';
import 'package:waslny/features/general/navigation/navigation_filters.dart';
import 'package:waslny/features/general/navigation/navigation_repo.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import '../../../../injector.dart' as injector;

enum NavigationTargetMode { toDestination, toPickup }

class UserTrackingScreen extends StatefulWidget {
  final TripAndServiceModel trip;
  final NavigationTargetMode mode;

  const UserTrackingScreen({
    super.key,
    required this.trip,
    this.mode = NavigationTargetMode.toDestination,
  });

  @override
  State<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends State<UserTrackingScreen> {
  MapLibreMapController? _mapController;
  StreamSubscription<Position>? _sub;

  late final NavigationRepo _repo;
  final KalmanFilterLatLng _kalman = KalmanFilterLatLng(15.0);

  List<ll.LatLng> _route = [];
  bool _routeReady = false;

  double _speedKmh = 0;
  ll.LatLng _lastCameraTarget = const ll.LatLng(30.0444, 31.2357);

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

  // ✅ المسافة المتبقية
  double get _remainingDistance {
    return (_routeLengthMeters - _sCurrent).clamp(0.0, _routeLengthMeters);
  }

  // ✅ حساب ETA (بناءً على السرعة المتوسطة)
  String get _eta {
    if (_speedKmh < 1) return "--:--";
    final remainingMeters = _remainingDistance;
    final remainingKm = remainingMeters / 1000;
    final hoursNeeded = remainingKm / _speedKmh;
    final minutesNeeded = hoursNeeded * 60;

    final hours = minutesNeeded ~/ 60;
    final minutes = (minutesNeeded % 60).toInt();

    if (hours > 0) {
      return "$hours:${minutes.toString().padLeft(2, '0')}";
    }
    return "${minutes}m";
  }

  bool _isFetchingRoute = false;
  int _lastRerouteTime = 0;

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
        ? widget.trip.fromLat
        : widget.trip.toLat;

    final String? lngStr = widget.mode == NavigationTargetMode.toPickup
        ? widget.trip.fromLong
        : widget.trip.toLong;

    final String nameStr = widget.mode == NavigationTargetMode.toPickup
        ? (widget.trip.from ?? "").trim()
        : ((widget.trip.serviceToName ?? widget.trip.to) ?? "").trim();

    final toLat = double.tryParse(latStr ?? "");
    final toLng = double.tryParse(lngStr ?? "");

    if (toLat == null || toLng == null) {
      throw Exception(
        "Invalid lat/long in trip => $latStr / $lngStr (mode=${widget.mode})",
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

        // ✅ تحقق من الاقتراب من الوجهة (20 متر)
        if (_remainingDistance < 20.0) {
          log(
            '✅ وصلت الوجهة! المسافة المتبقية: ${_remainingDistance.toStringAsFixed(2)}m',
          );
          _exitNavigationScreen();
        }
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

  // ✅ خروج تلقائي من الصفحة عند الوصول
  void _exitNavigationScreen() {
    Navigator.of(context).pop();
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
          // ✅ معلومات الوجهة في الأعلى
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
          // ✅ أيقونة الملاحة في المنتصف
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/icons/car_icon.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ✅ عرض السرعة في الأسفل اليمين
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
          // ✅ عرض المسافة المتبقية و ETA في الأسفل
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ✅ عنوان
                  Text(
                    "معلومات الرحلة",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ✅ صف المسافة و ETA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // المسافة المتبقية
                      Column(
                        children: [
                          const Icon(
                            Icons.directions_run,
                            color: Colors.orange,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${(_remainingDistance / 1000).toStringAsFixed(2)} كم",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "مسافة متبقية",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      // الفاصل
                      Container(width: 1, height: 80, color: Colors.grey[300]),
                      // ETA
                      Column(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: Colors.blue,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _eta,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "الوقت المتوقع",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ✅ شريط التقدم
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _routeLengthMeters > 0
                          ? (_sCurrent / _routeLengthMeters).clamp(0.0, 1.0)
                          : 0.0,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${((_sCurrent / _routeLengthMeters) * 100).toStringAsFixed(0)}% مكتمل",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
