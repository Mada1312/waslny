// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart' as ll;
// import 'package:maplibre_gl/maplibre_gl.dart';
// import 'package:waslny/core/api/base_api_consumer.dart';
// import 'package:waslny/features/general/navigation/navigation_filters.dart';
// import 'package:waslny/features/general/navigation/navigation_repo.dart';
// import 'package:waslny/injector.dart' as injector;

// class NavTools extends StatefulWidget {
//   const NavTools({super.key});

//   @override
//   State<NavTools> createState() => _NavToolsState();
// }

// // class _NavToolsState extends State<NavTools> {
//   MapLibreMapController? _mapController;
//   StreamSubscription<Position>? _sub;

//   late final NavigationRepo _repo;
//   final KalmanFilterLatLng _kalman = KalmanFilterLatLng(20.0);

//   List<ll.LatLng> _route = [];
//   bool _routeReady = false;

//   double _speedKmh = 0;
//   double _currentBearing = 0.0;
//   ll.LatLng? _lastCameraTarget;

//   bool _isFetchingRoute = false;
//   int _lastRerouteTime = 0;

//   static const String _styleUrl =
//       'https://tiles.baraddy.com/styles/basic-preview/style.json';
//   static const LatLng _fallback = LatLng(30.0444, 31.2357);

//   // ✅ Added: اسم الوجهة المعروض في الـ UI
//   String _destinationName = "جاري تحديد العنوان...";

//   @override
//   void initState() {
//     super.initState();
//     _repo = NavigationRepo(injector.serviceLocator<BaseApiConsumer>());

//     // ✅ منع الشاشة من الانطفاء عند بدء الملاحة
//     WakelockPlus.enable();

//     // ✅ لو الاسم متبعت جاهز استخدمه، غير كده اعمل Reverse Geocoding
//     final passedName = (widget.destinationName ?? "").trim();
//     if (passedName.isNotEmpty) {
//       _destinationName = passedName;
//     } else {
//       _resolveDestinationName(); // Reverse Geocoding
//     }
//   }

//   @override
//   void dispose() {
//     // ✅ السماح للشاشة بالانطفاء عند الخروج (توفير البطارية)
//     WakelockPlus.disable();
//     _sub?.cancel();
//     super.dispose();
//   }

//   // ======================= Reverse Geocoding =================================
//   Future<void> _resolveDestinationName() async {
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         widget.destination.latitude,
//         widget.destination.longitude,
//       ); // ✅ geocoding package [web:22]

//       if (placemarks.isEmpty) return;

//       final p = placemarks.first;

//       // صياغة بسيطة (عدّلها حسب اللي يناسبك)
//       final parts = <String>[
//         if ((p.street ?? "").trim().isNotEmpty) p.street!.trim(),
//         if ((p.subLocality ?? "").trim().isNotEmpty) p.subLocality!.trim(),
//         if ((p.locality ?? "").trim().isNotEmpty) p.locality!.trim(),
//         if ((p.administrativeArea ?? "").trim().isNotEmpty)
//           p.administrativeArea!.trim(),
//       ];

//       final name = parts.isEmpty ? "الموقع المحدد" : parts.join("، ");

//       if (!mounted) return;
//       setState(() => _destinationName = name);
//     } catch (e) {
//       log("Reverse geocoding error: $e");
//       if (!mounted) return;
//       setState(() => _destinationName = "الموقع المحدد");
//     }
//   }

//   // ======================= MAP STARTUP ======================================
//   void _onMapCreated(MapLibreMapController c) async {
//     _mapController = c;
//     await _start();
//   }

//   Future<void> _start() async {
//     await _ensurePermissions();

//     Position? startPos;
//     try {
//       startPos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.bestForNavigation,
//       );
//     } catch (e) {
//       log("Error getting location: $e");
//     }

//     final startLat = startPos?.latitude ?? _fallback.latitude;
//     final startLng = startPos?.longitude ?? _fallback.longitude;

//     _mapController?.moveCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: LatLng(startLat, startLng),
//           zoom: 17.0,
//           tilt: 0.0,
//           bearing: 0.0,
//         ),
//       ),
//     );

//     await _loadRoute(ll.LatLng(startLat, startLng), widget.destination);

//     const settings = LocationSettings(
//       accuracy: LocationAccuracy.bestForNavigation,
//       distanceFilter: 0,
//     );

//     _sub?.cancel();
//     _sub = Geolocator.getPositionStream(
//       locationSettings: settings,
//     ).listen(_onGps, onError: (e) => log("GPS stream error: $e"));
//   }

//   Future<void> _ensurePermissions() async {
//     if (!await Geolocator.isLocationServiceEnabled()) return;
//     var p = await Geolocator.checkPermission();
//     if (p == LocationPermission.denied) {
//       await Geolocator.requestPermission();
//     }
//   }

//   // ======================= ROUTE API ========================================
//   Future<void> _loadRoute(ll.LatLng from, ll.LatLng to) async {
//     if (_isFetchingRoute) return;
//     _isFetchingRoute = true;

//     try {
//       final json = await _repo.getRoute(
//         fromLat: from.latitude,
//         fromLng: from.longitude,
//         toLat: to.latitude,
//         toLng: to.longitude,
//       );

//       final decoded = _extractRoutePolyline(json);

//       if (decoded.isNotEmpty) {
//         setState(() {
//           _route = decoded;
//           _routeReady = true;
//         });
//         await _drawRoute();
//       }
//     } catch (e) {
//       log("Route API error: $e");
//     } finally {
//       _isFetchingRoute = false;
//     }
//   }

//   List<ll.LatLng> _extractRoutePolyline(Map<String, dynamic> json) {
//     dynamic coords = _deepGet(json, ["routes", 0, "geometry", "coordinates"]);
//     coords ??= _deepGet(json, ["geometry", "coordinates"]);

//     if (coords is List && coords.isNotEmpty) {
//       try {
//         return coords.map<ll.LatLng>((e) {
//           return ll.LatLng((e[1] as num).toDouble(), (e[0] as num).toDouble());
//         }).toList();
//       } catch (_) {}
//     }

//     dynamic polyStr = _deepGet(json, ["routes", 0, "geometry"]);
//     polyStr ??= _deepGet(json, ["geometry"]);

//     if (polyStr is String && polyStr.isNotEmpty) {
//       try {
//         final pts = PolylinePoints.decodePolyline(polyStr);
//         return pts.map((p) => ll.LatLng(p.latitude, p.longitude)).toList();
//       } catch (_) {}
//     }

//     return [];
//   }

//   dynamic _deepGet(dynamic root, List<dynamic> path) {
//     dynamic cur = root;
//     for (final key in path) {
//       if (cur == null) return null;
//       if (key is int) {
//         if (cur is List && cur.length > key)
//           cur = cur[key];
//         else
//           return null;
//       } else {
//         if (cur is Map && cur.containsKey(key))
//           cur = cur[key];
//         else
//           return null;
//       }
//     }
//     return cur;
//   }

//   Future<void> _drawRoute() async {
//     if (_mapController == null || _route.isEmpty) return;

//     await _mapController!.clearLines();
//     await _mapController!.addLine(
//       LineOptions(
//         geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
//         lineColor: "#4285F4",
//         lineWidth: 10.0,
//         lineOpacity: 1.0,
//         lineJoin: "round",
//       ),
//     );
//   }

//   // ======================= GPS LOOP =========================================
//   void _onGps(Position raw) async {
//     if (_mapController == null) return;

//     final now = DateTime.now().millisecondsSinceEpoch;

//     // 1. Filter
//     final filtered = _kalman.filter(
//       lat: raw.latitude,
//       lng: raw.longitude,
//       accuracy: raw.accuracy,
//       timestampMs: now,
//     );

//     // 2. Reroute Check
//     if (_routeReady && !_isFetchingRoute) {
//       final distToRoute = _getMinDistanceToRoute(filtered, _route);
//       if (distToRoute > 45.0 && (now - _lastRerouteTime > 5000)) {
//         _lastRerouteTime = now;
//         _loadRoute(filtered, widget.destination);
//       }
//     }

//     // 3. Snap Logic
//     ll.LatLng displayPos = filtered;
//     if (_routeReady) {
//       final snapped = RouteSnapper.snapToRoute(
//         filtered,
//         _route,
//         maxSnapMeters: 40,
//       );
//       final dist = const ll.Distance().as(
//         ll.LengthUnit.Meter,
//         filtered,
//         snapped,
//       );
//       if (dist < 40) displayPos = snapped;
//     }

//     // 4. Speed Logic
//     double instantSpeed = (raw.speed * 3.6);
//     if (instantSpeed < 0) instantSpeed = 0;
//     _speedKmh = (_speedKmh * 0.20) + (instantSpeed * 0.80);

//     // 5. Bearing Logic
//     double bearing = raw.heading;

//     if (_speedKmh < 5) {
//       bearing = _currentBearing;
//     } else {
//       if ((bearing - _currentBearing).abs() > 180) {
//         _currentBearing = bearing;
//       } else {
//         _currentBearing = (_currentBearing * 0.1) + (bearing * 0.9);
//       }
//     }

//     // 6. Camera Animation
//     int animDuration = 5000; // Normal smooth duration

//     if (_lastCameraTarget != null) {
//       final distMove = const ll.Distance().as(
//         ll.LengthUnit.Meter,
//         _lastCameraTarget!,
//         displayPos,
//       );
//     }
//     _lastCameraTarget = displayPos;

//     double z = 17.0;
//     if (_speedKmh > 80)
//       z = 15.0;
//     else if (_speedKmh > 40)
//       z = 16.0;

//     await _mapController!.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: LatLng(displayPos.latitude, displayPos.longitude),
//           bearing: _currentBearing,
//           zoom: z,
//           tilt: 50.0,
//         ),
//       ),
//       duration: Duration(milliseconds: animDuration),
//     );

//     if (mounted) setState(() {});
//   }

//   double _getMinDistanceToRoute(ll.LatLng p, List<ll.LatLng> poly) {
//     if (poly.isEmpty) return 0.0;
//     double minMeters = double.infinity;
//     final ll.Distance distance = const ll.Distance();
//     for (int i = 0; i < poly.length; i += 3) {
//       final d = distance.as(ll.LengthUnit.Meter, p, poly[i]);
//       if (d < minMeters) minMeters = d;
//     }
//     return minMeters;
//   }
// }
