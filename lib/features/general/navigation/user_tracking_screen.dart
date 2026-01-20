import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:http/http.dart' as http;
import 'package:waslny/core/exports.dart';

import 'package:waslny/core/real-time/captain_service.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/cubit/state.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

enum UserTrackingMode { toPickup, toDestination }

// ========================== HELPERS (self-contained) ==========================

/// Simple lat/lng smoother with Kalman-like behavior (practical + stable).
/// الهدف: يقلل jitter اللي بيخلّي العربية "تلف" وتطلع برا الطريق.
class KalmanFilterLatLng {
  final double processNoise; // bigger => follows raw faster
  double? _lat;
  double? _lng;
  double _varLat = 1.0;
  double _varLng = 1.0;
  int? _lastTs;

  KalmanFilterLatLng(this.processNoise);

  ll.LatLng filter({
    required double lat,
    required double lng,
    required double accuracy,
    required int timestampMs,
  }) {
    // first
    if (_lat == null || _lng == null || _lastTs == null) {
      _lat = lat;
      _lng = lng;
      _varLat = max(1.0, accuracy * accuracy);
      _varLng = max(1.0, accuracy * accuracy);
      _lastTs = timestampMs;
      return ll.LatLng(lat, lng);
    }

    final dt = max(1, timestampMs - _lastTs!);
    _lastTs = timestampMs;

    // prediction: uncertainty grows with time
    final q = processNoise * (dt / 1000.0);
    _varLat += q;
    _varLng += q;

    // measurement noise
    final r = max(10.0, accuracy) * max(10.0, accuracy);

    // kalman gain
    final kLat = _varLat / (_varLat + r);
    final kLng = _varLng / (_varLng + r);

    // update estimate
    _lat = _lat! + kLat * (lat - _lat!);
    _lng = _lng! + kLng * (lng - _lng!);

    // update variance
    _varLat = (1 - kLat) * _varLat;
    _varLng = (1 - kLng) * _varLng;

    return ll.LatLng(_lat!, _lng!);
  }
}

class RouteSnapResult {
  final ll.LatLng snapped;
  final double offRouteMeters;
  final int segIndex; // segment start index
  final double t; // 0..1
  const RouteSnapResult({
    required this.snapped,
    required this.offRouteMeters,
    required this.segIndex,
    required this.t,
  });
}

class RouteSnapper {
  static RouteSnapResult? snapToRouteDetailed(
    ll.LatLng p,
    List<ll.LatLng> route, {
    required double maxSnapMeters,
  }) {
    if (route.length < 2) return null;

    final refLatRad = p.latitude * pi / 180;
    final pxy = _toXY(p, refLatRad);

    double bestD2 = double.infinity;
    int bestI = 0;
    double bestT = 0.0;
    _XY bestProj = _XY(0, 0);

    for (int i = 0; i < route.length - 1; i++) {
      final a = _toXY(route[i], refLatRad);
      final b = _toXY(route[i + 1], refLatRad);

      final abx = b.x - a.x;
      final aby = b.y - a.y;
      final abLen2 = abx * abx + aby * aby;
      if (abLen2 == 0) continue;

      final apx = pxy.x - a.x;
      final apy = pxy.y - a.y;

      double t = (apx * abx + apy * aby) / abLen2;
      t = t.clamp(0.0, 1.0);

      final proj = _XY(a.x + t * abx, a.y + t * aby);
      final dx = pxy.x - proj.x;
      final dy = pxy.y - proj.y;

      final d2 = dx * dx + dy * dy;
      if (d2 < bestD2) {
        bestD2 = d2;
        bestI = i;
        bestT = t;
        bestProj = proj;
      }
    }

    final off = sqrt(bestD2);
    if (off > maxSnapMeters) {
      // still return it if caller wants off-route distance, but for display we usually reject
      return RouteSnapResult(
        snapped: _toLatLng(bestProj, refLatRad),
        offRouteMeters: off,
        segIndex: bestI,
        t: bestT,
      );
    }

    return RouteSnapResult(
      snapped: _toLatLng(bestProj, refLatRad),
      offRouteMeters: off,
      segIndex: bestI,
      t: bestT,
    );
  }

  static ll.LatLng snapToRoute(
    ll.LatLng p,
    List<ll.LatLng> route, {
    required double maxSnapMeters,
  }) {
    final r = snapToRouteDetailed(p, route, maxSnapMeters: maxSnapMeters);
    return r?.snapped ?? p;
  }

  static double remainingMetersFromSnap(
    RouteSnapResult snap,
    List<ll.LatLng> route,
  ) {
    if (route.length < 2) return 0.0;

    final i = snap.segIndex;
    if (i >= route.length - 1) return 0.0;

    double sum = 0.0;
    final dist = const ll.Distance();

    // remaining on current segment
    final segStart = route[i];
    final segEnd = route[i + 1];

    final segLen = dist.as(ll.LengthUnit.Meter, segStart, segEnd);
    final done = dist.as(ll.LengthUnit.Meter, segStart, snap.snapped);
    sum += max(0.0, segLen - done);

    // remaining segments
    for (int k = i + 1; k < route.length - 1; k++) {
      sum += dist.as(ll.LengthUnit.Meter, route[k], route[k + 1]);
    }

    return sum;
  }

  // ===== local projection helpers =====
  static const double _earth = 6378137.0;

  static _XY _toXY(ll.LatLng p, double refLatRad) {
    final lat = p.latitude * pi / 180;
    final lng = p.longitude * pi / 180;
    final x = _earth * lng * cos(refLatRad);
    final y = _earth * lat;
    return _XY(x, y);
  }

  static ll.LatLng _toLatLng(_XY xy, double refLatRad) {
    final lat = (xy.y / _earth) * 180 / pi;
    final lng = (xy.x / (_earth * cos(refLatRad))) * 180 / pi;
    return ll.LatLng(lat, lng);
  }
}

class _XY {
  final double x;
  final double y;
  const _XY(this.x, this.y);
}

class _OsrmRoute {
  final List<ll.LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  const _OsrmRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class UserTrackingScreen extends StatefulWidget {
  final TripAndServiceModel trip;
  final UserTrackingMode mode;

  const UserTrackingScreen({
    super.key,
    required this.trip,
    this.mode = UserTrackingMode.toDestination,
  });

  @override
  State<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends State<UserTrackingScreen> {
  MapLibreMapController? _mapController;
  late final CaptainTrackingService _trackingService;

  ll.LatLng? _prevPosForBearing;

  double _smoothAngle(double prev, double next, double alpha) {
    final diff = ((next - prev + 540) % 360) - 180; // [-180, 180]
    return (prev + alpha * diff + 360) % 360;
  }

  void _updateBearingFromPositions(ll.LatLng newPos) {
    if (_prevPosForBearing == null) {
      _prevPosForBearing = newPos;
      return;
    }

    final moved = const ll.Distance().as(
      ll.LengthUnit.Meter,
      _prevPosForBearing!,
      newPos,
    );

    // تجاهل jitter
    if (moved < 2) return;

    final b = _calculateBearing(_prevPosForBearing!, newPos);
    _currentBearing = _smoothAngle(_currentBearing, b, 0.25);
    _prevPosForBearing = newPos;
  }

  // ====== NEW (same pipeline idea as NavigationScreen) ======
  final KalmanFilterLatLng _kalman = KalmanFilterLatLng(20.0);
  bool _isFetchingRoute = false;
  int _lastRerouteTimeMs = 0;
  bool _isUpdateInFlight = false;

  static const int _rerouteCooldownMs = 5000;
  static const double _offRouteThresholdMeters = 45.0;
  static const double _snapMaxMeters = 40.0;
  // =========================================================

  bool _closedByTripEnd = false;
  bool _styleLoaded = false;
  bool _carImageAdded = false;
  bool _destinationPinAdded = false;
  Symbol? _captainSymbol;
  Symbol? _destinationSymbol;

  static const String _carAssetPath = 'assets/icons/car_icon.png';
  static const String _carIconName = 'car_icon';
  static const String _pinAssetPath = 'assets/icons/pin.png';
  static const String _pinIconName = 'location_pin';

  double _remainingDistanceKm = 0.0;
  Duration _eta = Duration.zero;
  DateTime? _arrivalTime;
  double _routeTotalKm = 0.0;

  static const double _expectedSpeedKmh = 40.0;

  Timer? _trackingTimer;
  static const Duration _trackingInterval = Duration(seconds: 3);
  bool _isTrackingActive = false;

  List<ll.LatLng> _route = [];
  bool _routeReady = false;

  ll.LatLng? _captainCurrentPos;
  ll.LatLng? _lastCameraTarget;

  double _currentBearing = 0.0;
  double _captainSpeedKmh = 0.0;

  ll.LatLng? _lastValidLocation;
  DateTime? _lastValidTime;

  CaptainConnectionState _connectionState = CaptainConnectionState.offline;
  int _consecutiveErrors = 0;

  String _destinationName = "جاري تحديد العنوان...";
  bool _isInfoPanelExpanded = true;

  late final ll.LatLng _destination;

  static const String _styleUrl =
      'https://tiles.baraddy.com/styles/basic-preview/style.json';
  static const LatLng _fallback = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();

    _trackingService = CaptainTrackingService(
      baseUrl: 'https://realtime.baraddy.com',
    );

    WakelockPlus.enable();

    final toLat = double.tryParse(
      widget.mode == UserTrackingMode.toPickup
          ? (widget.trip.fromLat ?? "")
          : (widget.trip.toLat ?? ""),
    );
    final toLng = double.tryParse(
      widget.mode == UserTrackingMode.toPickup
          ? (widget.trip.fromLong ?? "")
          : (widget.trip.toLong ?? ""),
    );

    if (toLat == null || toLng == null) {
      throw Exception("Invalid destination coordinates");
    }
    _destination = ll.LatLng(toLat, toLng);

    _destinationName = widget.mode == UserTrackingMode.toPickup
        ? (widget.trip.from ?? "مكان العميل")
        : ((widget.trip.to ?? widget.trip.serviceToName) ?? "الوجهة");

    log('📍 Destination: $_destinationName ($_destination)');
    log('👨‍✈️ Driver ID=${widget.trip.driver?.id}');
  }

  @override
  void dispose() {
    _stopTracking();
    WakelockPlus.disable();
    _trackingService.dispose();
    super.dispose();
  }

  bool _isLocationValid(ll.LatLng newLocation) {
    // Egypt bounds
    if (newLocation.latitude < 22 || newLocation.latitude > 32) return false;
    if (newLocation.longitude < 24 || newLocation.longitude > 35) return false;

    if (_lastValidLocation != null) {
      final dist = const ll.Distance().as(
        ll.LengthUnit.Meter,
        _lastValidLocation!,
        newLocation,
      );

      final now = DateTime.now();
      final dtSec = _lastValidTime == null
          ? 3
          : now.difference(_lastValidTime!).inSeconds.clamp(1, 60);

      const maxSpeedMps = 44.4; // 160 km/h
      final maxAllowed = (dtSec * maxSpeedMps) + 50;

      if (dist > maxAllowed) {
        log(
          '⚠️ Jump rejected: ${dist.toStringAsFixed(1)}m, allowed=${maxAllowed.toStringAsFixed(1)}m',
        );
        return false;
      }
    }

    return true;
  }

  void _updateConnectionState(CaptainConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      log('🔌 Connection state => $newState');
      if (mounted) setState(() {});
    }
  }

  void _handleTrackingError(Object e) {
    _consecutiveErrors++;
    log('❌ tracking error #$_consecutiveErrors => $e');

    if (_consecutiveErrors >= 3) {
      _updateConnectionState(CaptainConnectionState.offline);
    }
  }

  // ====================== ROUTE (OSRM full route) ======================
  Future<_OsrmRoute?> _fetchOsrmRoute({
    required ll.LatLng from,
    required ll.LatLng to,
  }) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson&alternatives=false&steps=false',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final r0 = routes[0];
      final coords = r0['geometry']['coordinates'] as List;

      final pts = coords.map<ll.LatLng>((c) {
        final lng = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        return ll.LatLng(lat, lng);
      }).toList();

      final dist = (r0['distance'] as num).toDouble(); // meters
      final dur = (r0['duration'] as num).toDouble(); // seconds

      return _OsrmRoute(
        points: pts,
        distanceMeters: dist,
        durationSeconds: dur,
      );
    } catch (e) {
      log("❌ OSRM route fetch error: $e");
      return null;
    }
  }

  Future<void> _loadRoute(ll.LatLng from, ll.LatLng to) async {
    if (_isFetchingRoute) return;
    _isFetchingRoute = true;

    try {
      final r = await _fetchOsrmRoute(from: from, to: to);
      if (r == null || r.points.isEmpty) return;

      _route = r.points;
      _routeReady = true;

      _routeTotalKm = r.distanceMeters / 1000.0;

      if (_remainingDistanceKm <= 0) {
        _remainingDistanceKm = _routeTotalKm;
      }

      // تقدر تخلي ETA من duration لو عايز أدق:
      // _eta = Duration(seconds: r.durationSeconds.round());
      // _arrivalTime = DateTime.now().add(_eta);

      // أو تفضل على بتاعتك:
      _eta = _etaFromKm(_remainingDistanceKm);
      _arrivalTime = DateTime.now().add(_eta);

      if (_styleLoaded) await _drawRoute();
    } catch (e) {
      log("❌ loadRoute error: $e");
    } finally {
      _isFetchingRoute = false;
    }
  }

  // =====================================================================

  Duration _etaFromKm(double km) {
    if (km <= 0) return Duration.zero;
    final speed = (_captainSpeedKmh >= 10)
        ? _captainSpeedKmh
        : _expectedSpeedKmh;
    final hours = km / speed;
    final seconds = (hours * 3600).round();
    return Duration(seconds: seconds);
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return "0 min";
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) return "$hours:${minutes.toString().padLeft(2, '0')} h";
    return "$minutes min";
  }

  String _formatArrivalTime(DateTime? dt) {
    if (dt == null) return "--";
    int hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final suffix = isPm ? "م" : "ص";
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute $suffix";
  }

  Future<void> _ensureCarIconAdded() async {
    if (_mapController == null || !_styleLoaded || _carImageAdded) return;
    try {
      final ByteData bytes = await rootBundle.load(_carAssetPath);
      final Uint8List list = bytes.buffer.asUint8List();
      await _mapController!.addImage(_carIconName, list);
      _carImageAdded = true;
    } catch (e) {
      log('❌ Error adding car icon: $e');
    }
  }

  Future<void> _ensureDestinationPinAdded() async {
    if (_mapController == null || !_styleLoaded || _destinationPinAdded) return;
    try {
      final ByteData bytes = await rootBundle.load(_pinAssetPath);
      final Uint8List list = bytes.buffer.asUint8List();
      await _mapController!.addImage(_pinIconName, list);
      _destinationPinAdded = true;
    } catch (e) {
      log('⚠️ Could not load destination pin: $e');
    }
  }

  Future<void> _upsertCaptainMarker(ll.LatLng pos) async {
    final c = _mapController;
    if (c == null || !_styleLoaded) return;

    try {
      await _ensureCarIconAdded();
      final geo = LatLng(pos.latitude, pos.longitude);

      if (_captainSymbol == null) {
        _captainSymbol = await c.addSymbol(
          SymbolOptions(
            geometry: geo,
            iconImage: _carIconName,
            iconSize: 0.2,
            iconRotate: _currentBearing,
          ),
        );
      } else {
        await c.updateSymbol(
          _captainSymbol!,
          SymbolOptions(geometry: geo, iconRotate: _currentBearing),
        );
      }
    } catch (e) {
      log('❌ Error updating captain marker: $e');
    }
  }

  Future<void> _addDestinationPin() async {
    final c = _mapController;
    if (c == null || !_styleLoaded) return;

    try {
      await _ensureDestinationPinAdded();
      final geo = LatLng(_destination.latitude, _destination.longitude);

      if (_destinationSymbol == null) {
        _destinationSymbol = await c.addSymbol(
          SymbolOptions(geometry: geo, iconImage: _pinIconName, iconSize: 1.5),
        );
      }
    } catch (e) {
      log('⚠️ Error adding destination pin: $e');
    }
  }

  Future<void> _afterStyleReady() async {
    if (!mounted) return;

    await _ensureCarIconAdded();
    await _addDestinationPin();

    if (_routeReady && _route.isNotEmpty) {
      await _drawRoute();
    }

    if (_captainCurrentPos != null) {
      await _upsertCaptainMarker(_captainCurrentPos!);
    }

    if (mounted) setState(() {});
  }

  void _startTracking() {
    if (_isTrackingActive) return;

    final driverId = widget.trip.driver?.id;
    if (driverId == null) {
      log('❌ startTracking: Missing driver id');
      return;
    }

    _isTrackingActive = true;
    _updateCaptainPosition(); // first fetch

    _trackingTimer = Timer.periodic(_trackingInterval, (_) async {
      await _updateCaptainPosition();
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTrackingActive = false;
  }

  // ====================== NEW: same pipeline as NavigationScreen ======================
  void _updateSpeedKmh({
    required double? speedMpsFromServer,
    required ll.LatLng rawPos,
    required DateTime ts,
  }) {
    double speedMps = (speedMpsFromServer ?? 0.0);

    // لو السيرفر مبعتش speed → قدّرها من الحركة
    if (speedMpsFromServer == null &&
        _lastValidLocation != null &&
        _lastValidTime != null) {
      final dt = ts.difference(_lastValidTime!).inMilliseconds;
      if (dt > 0) {
        final distM = const ll.Distance().as(
          ll.LengthUnit.Meter,
          _lastValidLocation!,
          rawPos,
        );
        final est = distM / (dt / 1000.0);
        // clamp عشان ما يطلعش شاذ
        speedMps = est.clamp(0.0, 60.0); // 216 km/h max
      }
    }

    double instantKmh = speedMps * 3.6;
    if (instantKmh < 0) instantKmh = 0;

    // smoothing زي NavigationScreen
    _captainSpeedKmh = (_captainSpeedKmh * 0.20) + (instantKmh * 0.80);
  }

  void _updateBearingFromMovement({required ll.LatLng displayPos}) {
    // نفس فكرة NavigationScreen: لو السرعة قليلة → ثبّت الاتجاه
    if (_captainSpeedKmh < 5) return;

    if (_lastCameraTarget != null) {
      final moved = const ll.Distance().as(
        ll.LengthUnit.Meter,
        _lastCameraTarget!,
        displayPos,
      );

      if (moved < 3) return;

      final b = _calculateBearing(_lastCameraTarget!, displayPos);

      // منع قفزات 180°
      if ((b - _currentBearing).abs() > 180) {
        _currentBearing = b;
      } else {
        _currentBearing = (_currentBearing * 0.1) + (b * 0.9);
      }
    }
  }

  Future<void> _applyTrackingPipeline({
    required ll.LatLng rawPos,
    required double? speedMps,
    required DateTime updatedAt,
  }) async {
    if (_mapController == null) return;

    final nowMs = updatedAt.millisecondsSinceEpoch;

    // 1) Filter (no accuracy from server → constant)
    final filtered = _kalman.filter(
      lat: rawPos.latitude,
      lng: rawPos.longitude,
      accuracy: 25,
      timestampMs: nowMs,
    );

    // 2) Ensure route first time
    if (!_routeReady && !_isFetchingRoute) {
      await _loadRoute(filtered, _destination);
    }

    // 3) Reroute Check (distance-to-route)
    if (_routeReady && !_isFetchingRoute && _route.length >= 2) {
      final snapFar = RouteSnapper.snapToRouteDetailed(
        filtered,
        _route,
        maxSnapMeters: 5000,
      );
      if (snapFar != null) {
        final distToRoute = snapFar.offRouteMeters;
        if (distToRoute > _offRouteThresholdMeters &&
            (nowMs - _lastRerouteTimeMs > _rerouteCooldownMs)) {
          _lastRerouteTimeMs = nowMs;
          await _loadRoute(filtered, _destination);
        }
      }
    }

    // 4) Snap Logic (keep marker on route)
    ll.LatLng displayPos = filtered;
    RouteSnapResult? snap = (_routeReady && _route.length >= 2)
        ? RouteSnapper.snapToRouteDetailed(
            filtered,
            _route,
            maxSnapMeters: _snapMaxMeters,
          )
        : null;

    if (snap != null) {
      if (snap.offRouteMeters <= _snapMaxMeters) {
        displayPos = snap.snapped;
      } else {
        snap = null; // بعيد جدًا → متعرضش snapped
      }
    }

    // 5) Speed Logic (smooth)
    _updateSpeedKmh(
      speedMpsFromServer: speedMps,
      rawPos: rawPos,
      ts: updatedAt,
    );

    // 6) Bearing Logic (from movement + smooth)
    // _updateBearingFromMovement(displayPos: displayPos);
    _updateBearingFromPositions(displayPos);

    // 7) Remaining + ETA (بدون OSRM polling)
    if (snap != null) {
      final remainM = RouteSnapper.remainingMetersFromSnap(snap, _route);
      _remainingDistanceKm = (remainM / 1000.0).clamp(0.0, 999999.0);
    } else {
      // fallback لو مفيش snap
      final d = const ll.Distance().as(
        ll.LengthUnit.Meter,
        displayPos,
        _destination,
      );
      _remainingDistanceKm = (d / 1000.0).clamp(0.0, 999999.0);
    }

    _eta = _etaFromKm(_remainingDistanceKm);
    _arrivalTime = DateTime.now().add(_eta);

    _captainCurrentPos = displayPos;

    // marker
    await _upsertCaptainMarker(displayPos);

    // camera (always follow)
    await _animateCamera(displayPos);

    if (mounted) setState(() {});
  }
  // ==========================================================================

  Future<void> _updateCaptainPosition() async {
    if (_isUpdateInFlight) return;
    _isUpdateInFlight = true;

    try {
      final driverId = widget.trip.driver?.id;
      if (driverId == null) {
        _stopTracking();
        return;
      }

      final tracking = await _trackingService.getTrackingByDriverId(
        driverId,
        historyLimit: 100,
      );

      _consecutiveErrors = 0;
      _updateConnectionState(tracking.connectionState);

      ll.LatLng? pos;
      double? speed;
      DateTime? updatedAtServer;

      final live = tracking.liveLocation;
      if (live != null) {
        pos = ll.LatLng(live.latitude, live.longitude);
        speed = live.speed;
        updatedAtServer = live.updatedAt;
      } else if (tracking.history.isNotEmpty) {
        final h0 = tracking.history.first;
        pos = ll.LatLng(h0.latitude, h0.longitude);
        speed = h0.speed;
        updatedAtServer = h0.timestamp;
      } else {
        log('⚠️ No liveLocation and empty history');
        return;
      }

      if (updatedAtServer != null) {
        final ageSec = DateTime.now().difference(updatedAtServer).inSeconds;
        if (ageSec > 25) _updateConnectionState(CaptainConnectionState.idle);
      }

      if (pos == null) return;
      if (!_isLocationValid(pos)) return;

      final frameNow = DateTime.now();

      final serverSpeed = (speed != null && speed.isFinite && speed > 0.1)
          ? speed
          : null;

      await _applyTrackingPipeline(
        rawPos: pos,
        speedMps: serverSpeed,
        updatedAt: frameNow,
      );

      _lastValidTime = frameNow;
      _lastValidLocation = pos;
    } catch (e, st) {
      log('❌ _updateCaptainPosition error: $e');
      log('🧵 $st');
      _handleTrackingError(e);
    } finally {
      _isUpdateInFlight = false;
    }
  }

  double _calculateBearing(ll.LatLng from, ll.LatLng to) {
    final lat1 = from.latitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final dLng = (to.longitude - from.longitude) * pi / 180;

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  Future<void> _animateCamera(ll.LatLng target) async {
    if (_mapController == null) return;

    final movedMeters = _lastCameraTarget == null
        ? 999999.0
        : const ll.Distance().as(
            ll.LengthUnit.Meter,
            _lastCameraTarget!,
            target,
          );

    // نفس سلوكك: مايتحركش لو الحركة ضعيفة جدًا
    if (movedMeters >= 3) {
      _lastCameraTarget = target;

      double zoom = 17.0;
      if (_captainSpeedKmh > 80) {
        zoom = 15.0;
      } else if (_captainSpeedKmh > 40) {
        zoom = 16.0;
      }

      try {
        await _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(target.latitude, target.longitude),
              bearing: _currentBearing,
              zoom: zoom,
              tilt: 50.0,
            ),
          ),
          duration: const Duration(milliseconds: 900),
        );
      } catch (e) {
        log('❌ Error animating camera: $e');
      }
    }
  }

  void _onMapCreated(MapLibreMapController c) async {
    _mapController = c;
    await _initializeMap();
  }

  Future<void> _initializeMap() async {
    final driverLat = double.tryParse(widget.trip.driver?.lat ?? "");
    final driverLng = double.tryParse(widget.trip.driver?.long ?? "");

    if (driverLat != null && driverLng != null) {
      _captainCurrentPos = ll.LatLng(driverLat, driverLng);
      _lastValidLocation = _captainCurrentPos;
      _lastValidTime = DateTime.now();

      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(driverLat, driverLng), zoom: 17.0),
        ),
      );

      // route prefetch من أول نقطة معروفة
      await _loadRoute(_captainCurrentPos!, _destination);
    } else {
      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(target: _fallback, zoom: 15),
        ),
      );
    }

    _startTracking();
  }

  Future<void> _drawRoute() async {
    if (!_styleLoaded) return;
    if (_mapController == null || _route.isEmpty) return;

    try {
      await _mapController!.clearLines();
      await _mapController!.addLine(
        LineOptions(
          geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          lineColor: "#4285F4",
          lineWidth: 10.0,
          lineOpacity: 0.85,
          lineJoin: "round",
        ),
      );
    } catch (e) {
      log('❌ Error drawing route: $e');
    }
  }

  void _goBackToHome() => Navigator.of(context).pop();

  Widget _buildConnectionStatus() {
    final color = _connectionState == CaptainConnectionState.online
        ? Colors.green
        : _connectionState == CaptainConnectionState.idle
        ? Colors.orange
        : Colors.red;

    final text = _connectionState == CaptainConnectionState.online
        ? "متصل"
        : _connectionState == CaptainConnectionState.idle
        ? "خامل"
        : "غير متصل";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arrivalText = _formatArrivalTime(_arrivalTime);

    return BlocListener<UserHomeCubit, UserHomeState>(
      listenWhen: (_, state) => state is TripEndedState,
      listener: (context, state) {
        if (_closedByTripEnd) return;
        _closedByTripEnd = true;

        _stopTracking();
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).maybePop();
      },

      child: Scaffold(
        body: Stack(
          children: [
            MapLibreMap(
              styleString: _styleUrl,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: () async {
                _styleLoaded = true;
                await _afterStyleReady();
              },
              initialCameraPosition: const CameraPosition(
                target: _fallback,
                zoom: 15,
              ),
              myLocationEnabled: false,
              compassEnabled: false,
            ),
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(child: _buildConnectionStatus()),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 20),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(
                        () => _isInfoPanelExpanded = !_isInfoPanelExpanded,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "معلومات الرحلة",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isInfoPanelExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.mode == UserTrackingMode.toPickup
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
                                if (widget.trip.driver?.name != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "السائق: ${widget.trip.driver!.name}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.flag,
                                      size: 18,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "وقت الوصول المتوقع: $arrivalText",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: Colors.blue,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDuration(_eta),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "وقت الرحلة",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 80,
                                  color: Colors.grey[300],
                                ),
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.orange,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "km ${_remainingDistanceKm.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "مسافة المتبقية",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_routeTotalKm > 0)
                              Text(
                                "الإجمالي: ${_routeTotalKm.toStringAsFixed(2)} km",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _goBackToHome,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.home_rounded),
                                label: const Text(
                                  "الرجوع للصفحة الرئيسية",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      crossFadeState: _isInfoPanelExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
