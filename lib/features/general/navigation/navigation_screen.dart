import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:waslny/core/api/base_api_consumer.dart';
import 'package:waslny/core/real-time/captain_service.dart';
import 'package:waslny/core/real-time/realtime_service.dart';
import 'package:waslny/features/general/navigation/navigation_filters.dart';
import 'package:waslny/features/general/navigation/navigation_repo.dart';
import '../../../../injector.dart' as injector;

// ✅ Added مرة واحدة فقط
enum NavigationTargetMode { toPickup, toDropoff }

class NavigationScreen extends StatefulWidget {
  final ll.LatLng destination;
  final int driverId;

  // ✅ Added
  final NavigationTargetMode mode;

  /// لو اتبعت اسم جاهز هنعرضه مباشرة، لو null/فارغ هنعمله Reverse Geocoding.
  final String? destinationName;

  const NavigationScreen({
    super.key,
    required this.destination,
    this.mode = NavigationTargetMode.toDropoff,
    this.destinationName,
    required this.driverId,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  MapLibreMapController? _mapController;
  StreamSubscription<Position>? _sub;

  late final CaptainTrackingService _tracking; // للقراءة
  late final RealtimeService _realtime; // للإرسال
  String? _internalId; // uuid
  Timer? _pushTimer;

  ll.LatLng? _lastPos;
  double _lastSpeedMps = 0;
  double _lastBearing = 0;

  bool _pushInFlight = false;

  bool _styleLoaded = false;

  late final NavigationRepo _repo;
  final KalmanFilterLatLng _kalman = KalmanFilterLatLng(20.0);

  List<ll.LatLng> _route = [];
  bool _routeReady = false;

  double _speedKmh = 0;
  double _currentBearing = 0.0;
  ll.LatLng? _lastCameraTarget;

  bool _isFetchingRoute = false;
  int _lastRerouteTime = 0;

  static const String _styleUrl =
      'https://tiles.baraddy.com/styles/basic-preview/style.json';
  static const LatLng _fallback = LatLng(30.0444, 31.2357);

  // ✅ Added: اسم الوجهة المعروض في الـ UI
  String _destinationName = "جاري تحديد العنوان...";

  @override
  void initState() {
    super.initState();
    _tracking = CaptainTrackingService(baseUrl: 'https://realtime.baraddy.com');
    _realtime = RealtimeService();

    _loadInternalId();

    _pushTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _pushRealtime();
    });

    _repo = NavigationRepo(injector.serviceLocator<BaseApiConsumer>());

    // ✅ منع الشاشة من الانطفاء عند بدء الملاحة
    WakelockPlus.enable();

    // ✅ لو الاسم متبعت جاهز استخدمه، غير كده اعمل Reverse Geocoding
    final passedName = (widget.destinationName ?? "").trim();
    if (passedName.isNotEmpty) {
      _destinationName = passedName;
    } else {
      _resolveDestinationName(); // Reverse Geocoding
    }
  }

  @override
  void dispose() {
    // ✅ السماح للشاشة بالانطفاء عند الخروج (توفير البطارية)
    _pushTimer?.cancel();
    _tracking.dispose();
    _realtime.dispose();
    _sub?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _loadInternalId() async {
    try {
      final data = await _tracking.getTrackingByDriverId(widget.driverId);
      _internalId = data.captain.internalId;
      log("✅ internalId loaded: $_internalId");
    } catch (e) {
      log("❌ Failed to load internalId: $e");
    }
  }

  // ======================= Reverse Geocoding =================================
  Future<void> _resolveDestinationName() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        widget.destination.latitude,
        widget.destination.longitude,
      ); // ✅ geocoding package [web:22]

      if (placemarks.isEmpty) return;

      final p = placemarks.first;

      // صياغة بسيطة (عدّلها حسب اللي يناسبك)
      final parts = <String>[
        if ((p.street ?? "").trim().isNotEmpty) p.street!.trim(),
        if ((p.subLocality ?? "").trim().isNotEmpty) p.subLocality!.trim(),
        if ((p.locality ?? "").trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? "").trim().isNotEmpty)
          p.administrativeArea!.trim(),
      ];

      final name = parts.isEmpty ? "الموقع المحدد" : parts.join("، ");

      if (!mounted) return;
      setState(() => _destinationName = name);
    } catch (e) {
      log("Reverse geocoding error: $e");
      if (!mounted) return;
      setState(() => _destinationName = "الموقع المحدد");
    }
  }

  // ======================= MAP STARTUP ======================================
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

    await _loadRoute(ll.LatLng(startLat, startLng), widget.destination);

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

  // ======================= ROUTE API ========================================
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

      log(
        "Route decoded points = ${decoded.length}, styleLoaded=$_styleLoaded",
      );

      if (decoded.isEmpty) {
        // لو مفيش نقاط، اعتبرها route غير جاهزة
        if (mounted) {
          setState(() {
            _route = [];
            _routeReady = false;
          });
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        _route = decoded;
        _routeReady = true;
      });

      // ✅ ارسم بس لما الستايل يكون جاهز
      if (_styleLoaded) {
        await _drawRoute();
      }
      // لو الستايل مش جاهز، onStyleLoadedCallback هيعمل draw تلقائي
    } catch (e, st) {
      log("Route API error: $e\n$st");
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
        if (cur is List && cur.length > key)
          cur = cur[key];
        else
          return null;
      } else {
        if (cur is Map && cur.containsKey(key))
          cur = cur[key];
        else
          return null;
      }
    }
    return cur;
  }

  Future<void> _drawRoute() async {
    if (_mapController == null || _route.isEmpty) return;
    if (!_styleLoaded) return; // ✅ مهم جداً

    await _mapController!.clearLines();
    await _mapController!.addLine(
      LineOptions(
        geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        lineColor: "#4285F4",
        lineWidth: 10.0,
        lineOpacity: 1.0,
        lineJoin: "round",
      ),
    );
  }

  // ======================= GPS LOOP =========================================
  void _onGps(Position raw) async {
    if (_mapController == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Filter
    final filtered = _kalman.filter(
      lat: raw.latitude,
      lng: raw.longitude,
      accuracy: raw.accuracy,
      timestampMs: now,
    );

    // 2. Reroute Check
    if (_routeReady && !_isFetchingRoute) {
      final distToRoute = _getMinDistanceToRoute(filtered, _route);
      if (distToRoute > 45.0 && (now - _lastRerouteTime > 5000)) {
        _lastRerouteTime = now;
        _loadRoute(filtered, widget.destination);
      }
    }

    // 3. Snap Logic
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
      if (dist < 40) displayPos = snapped;
    }

    // 4. Speed Logic
    double instantSpeed = (raw.speed * 3.6);
    if (instantSpeed < 0) instantSpeed = 0;
    _speedKmh = (_speedKmh * 0.20) + (instantSpeed * 0.80);

    // 5. Bearing Logic
    double bearing = raw.heading;

    if (_speedKmh < 5) {
      bearing = _currentBearing;
    } else {
      if ((bearing - _currentBearing).abs() > 180) {
        _currentBearing = bearing;
      } else {
        _currentBearing = (_currentBearing * 0.1) + (bearing * 0.9);
      }
    }

    // 6. Camera Animation
    int animDuration = 5000; // Normal smooth duration

    if (_lastCameraTarget != null) {
      final distMove = const ll.Distance().as(
        ll.LengthUnit.Meter,
        _lastCameraTarget!,
        displayPos,
      );
    }
    _lastCameraTarget = displayPos;

    double z = 17.0;
    if (_speedKmh > 80)
      z = 15.0;
    else if (_speedKmh > 40)
      z = 16.0;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(displayPos.latitude, displayPos.longitude),
          bearing: _currentBearing,
          zoom: z,
          tilt: 50.0,
        ),
      ),
      duration: Duration(milliseconds: animDuration),
    );

    _lastPos = displayPos;
    _lastSpeedMps = raw.speed.isFinite ? raw.speed : 0; // m/s
    _lastBearing = _currentBearing;

    if (mounted) setState(() {});
  }

  double _getMinDistanceToRoute(ll.LatLng p, List<ll.LatLng> poly) {
    if (poly.isEmpty) return 0.0;
    double minMeters = double.infinity;
    final ll.Distance distance = const ll.Distance();
    for (int i = 0; i < poly.length; i += 3) {
      final d = distance.as(ll.LengthUnit.Meter, p, poly[i]);
      if (d < minMeters) minMeters = d;
    }
    return minMeters;
  }

  // ======================= Real Time ======================================
  Future<void> _pushRealtime() async {
    if (_pushInFlight) return;
    if (_lastPos == null) return;
    if (_internalId == null) return; // لسه ما اتحملش
    _pushInFlight = true;

    final p = _lastPos!;
    try {
      await _realtime.updateLocation(
        internalId: _internalId!, // ✅ uuid
        lat: p.latitude,
        lng: p.longitude,
        speed: _lastSpeedMps, // m/s
        heading: _lastBearing, // bearing
        accuracy: 25,
      );
    } catch (e) {
      log("Realtime push error: $e");
    } finally {
      _pushInFlight = false;
    }
  }

  // ======================= Google Maps ======================================
  Future<void> _openGoogleMaps() async {
    final lat = widget.destination.latitude;
    final lng = widget.destination.longitude;

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log("Cannot launch Google Maps");
      }
    } catch (e) {
      log("Error opening Google Maps: $e");
    }
  }

  // ======================= Finish Trip Stub ======================
  // ✅ علشان build اللي انت عايزه فيه SwipeButton و _finishTrip
  // لو عندك implementation حطها مكان ده
  Future<void> _finishTrip() async {
    Navigator.of(context).maybePop();
  }

  // ======================= BUILD (زي ما طلبت) ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MapLibreMap(
          //   styleString: _styleUrl,
          //   onMapCreated: _onMapCreated,
          //   initialCameraPosition: const CameraPosition(
          //     target: _fallback,
          //     zoom: 15,
          //   ),
          //   myLocationEnabled: false,
          //   compassEnabled: false,
          // ),
          MapLibreMap(
            styleString: _styleUrl,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: () async {
              _styleLoaded = true;

              // لو الـ route كانت اتحسبت قبل تحميل الستايل، ارسمها هنا
              if (_route.isNotEmpty) {
                await _drawRoute();
              }
            },
            initialCameraPosition: const CameraPosition(
              target: _fallback,
              zoom: 15,
            ),
            myLocationEnabled: false,
            compassEnabled: false,
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
                  BoxShadow(color: Colors.black12, blurRadius: 15),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mode == NavigationTargetMode.toPickup
                        ? "مكان العميل:"
                        : "الوجهة:",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
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
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 15),
                        ],
                      ),
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
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
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
