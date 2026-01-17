// import 'dart:async';
// import 'dart:developer';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:latlong2/latlong.dart' as ll;
// import 'package:maplibre_gl/maplibre_gl.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:waslny/core/api/base_api_consumer.dart';
// import 'package:waslny/features/general/navigation/navigation_filters.dart';
// import 'package:waslny/features/general/navigation/navigation_repo.dart';
// import 'package:waslny/core/real-time/realtime_api.dart';
// import 'package:waslny/features/user/home/data/models/get_home_model.dart';
// import '../../../../injector.dart' as injector;

// enum UserTrackingMode { toPickup, toDestination }

// class UserTrackingScreen extends StatefulWidget {
//   final TripAndServiceModel trip;
//   final UserTrackingMode mode;

//   const UserTrackingScreen({
//     super.key,
//     required this.trip,
//     this.mode = UserTrackingMode.toDestination,
//   });

//   @override
//   State<UserTrackingScreen> createState() => _UserTrackingScreenState();
// }

// class _UserTrackingScreenState extends State<UserTrackingScreen> {
//   // ==================== Controllers ====================
//   MapLibreMapController? _mapController;
//   late final NavigationRepo _navRepo;
//   late final RealtimeApiClient _realtimeClient;

//   // ==================== Real-time Tracking ====================
//   Timer? _trackingTimer;
//   static const Duration _trackingInterval = Duration(seconds: 3);
//   bool _isTrackingActive = false;

//   // ==================== Route & Position ====================
//   List<ll.LatLng> _route = [];
//   bool _routeReady = false;
//   ll.LatLng? _captainCurrentPos;
//   ll.LatLng? _lastCameraTarget;

//   // ==================== Smoothing ====================
//   final KalmanFilterLatLng _kalman = KalmanFilterLatLng(20.0);
//   double _currentBearing = 0.0;
//   double _captainSpeedKmh = 0.0;

//   // ==================== UI State ====================
//   String _destinationName = "جاري تحديد العنوان...";
//   bool _isInfoPanelExpanded = true;
//   bool _isFetchingRoute = false;
//   int _lastRerouteTime = 0;

//   // ==================== Destination ====================
//   late final ll.LatLng _destination;

//   static const String _styleUrl =
//       'https://tiles.baraddy.com/styles/basic-preview/style.json';
//   static const LatLng _fallback = LatLng(30.0444, 31.2357);

//   @override
//   void initState() {
//     super.initState();
//     _navRepo = NavigationRepo(injector.serviceLocator<BaseApiConsumer>());
//     _realtimeClient = RealtimeApiClient(
//       baseUrl: 'https://realtime.baraddy.com',
//     );

//     WakelockPlus.enable();

//     // تحديد الوجهة من الـ trip
//     final toLat = double.tryParse(
//       widget.mode == UserTrackingMode.toPickup
//           ? (widget.trip.fromLat ?? "")
//           : (widget.trip.toLat ?? ""),
//     );
//     final toLng = double.tryParse(
//       widget.mode == UserTrackingMode.toPickup
//           ? (widget.trip.fromLong ?? "")
//           : (widget.trip.toLong ?? ""),
//     );

//     if (toLat == null || toLng == null) {
//       throw Exception("Invalid destination coordinates");
//     }

//     _destination = ll.LatLng(toLat, toLng);
//     _destinationName = widget.mode == UserTrackingMode.toPickup
//         ? (widget.trip.from ?? "مكان العميل")
//         : ((widget.trip.to ?? widget.trip.serviceToName) ?? "الوجهة");

//     log('📍 Destination: $_destinationName ($_destination)');
//     log('👨‍✈️ Captain: ${widget.trip.driver?.name}');
//   }

//   @override
//   void dispose() {
//     _stopTracking();
//     WakelockPlus.disable();
//     _realtimeClient.dispose();
//     super.dispose();
//   }

//   // ==================== REALTIME TRACKING ====================
//   void _startTracking() {
//     if (_isTrackingActive) return;
//     if (widget.trip.driver?.captainInternalId == null) {
//       log('❌ No captainInternalId available');
//       return;
//     }

//     log('🚀 Starting real-time captain tracking...');
//     _isTrackingActive = true;

//     _trackingTimer = Timer.periodic(_trackingInterval, (_) async {
//       await _updateCaptainPosition();
//     });
//   }

//   void _stopTracking() {
//     _trackingTimer?.cancel();
//     _trackingTimer = null;
//     _isTrackingActive = false;
//     log('⏹️ Tracking stopped');
//   }

//   Future<void> _updateCaptainPosition() async {
//     try {
//       final captainInternalId = widget.trip.driver?.captainInternalId;
//       if (captainInternalId == null) {
//         log('❌ Missing captainInternalId');
//         _stopTracking();
//         return;
//       }

//       // 📍 استدعاء API لجلب موقع الكابتن الأخير
//       final location = await _realtimeClient.getCaptainLocation(
//         captainInternalId: captainInternalId,
//       );

//       if (!mounted) return;

//       final now = DateTime.now().millisecondsSinceEpoch;

//       // 1️⃣ تطبيق Kalman Filter للتنعيم
//       final filtered = _kalman.filter(
//         lat: location.latitude,
//         lng: location.longitude,
//         accuracy: location.accuracy ?? 5.0,
//         timestampMs: now,
//       );

//       log('📍 Captain at: (${filtered.latitude}, ${filtered.longitude})');

//       // 2️⃣ فحص الرجوع للطريق (Reroute Check)
//       if (_routeReady && !_isFetchingRoute) {
//         final distToRoute = _getMinDistanceToRoute(filtered, _route);
//         if (distToRoute > 45.0 && (now - _lastRerouteTime > 5000)) {
//           log(
//             '🔄 Captain off-route (${distToRoute.toStringAsFixed(1)}m), rerouting...',
//           );
//           _lastRerouteTime = now;
//           _loadRoute(filtered, _destination);
//         }
//       }

//       // 3️⃣ Snap to route
//       ll.LatLng displayPos = filtered;
//       if (_routeReady) {
//         final snapped = RouteSnapper.snapToRoute(
//           filtered,
//           _route,
//           maxSnapMeters: 40,
//         );
//         final dist = const ll.Distance().as(
//           ll.LengthUnit.Meter,
//           filtered,
//           snapped,
//         );
//         if (dist < 40) displayPos = snapped;
//       }

//       // 4️⃣ Speed calculation
//       double instantSpeed = (location.speed ?? 0.0) * 3.6;
//       if (instantSpeed < 0) instantSpeed = 0;
//       _captainSpeedKmh = (_captainSpeedKmh * 0.20) + (instantSpeed * 0.80);

//       // 5️⃣ Bearing smoothing
//       double bearing = location.heading ?? _currentBearing;
//       if (_captainSpeedKmh < 5) {
//         bearing = _currentBearing;
//       } else {
//         final diff = (bearing - _currentBearing).abs();
//         if (diff > 180) {
//           _currentBearing = bearing;
//         } else {
//           _currentBearing = (_currentBearing * 0.1) + (bearing * 0.9);
//         }
//       }

//       _captainCurrentPos = displayPos;

//       // 6️⃣ Camera animation
//       int animDuration = 3000; // 3 ثواني = نفس polling interval
//       _lastCameraTarget = displayPos;

//       double z = 17.0;
//       if (_captainSpeedKmh > 80)
//         z = 15.0;
//       else if (_captainSpeedKmh > 40)
//         z = 16.0;

//       await _mapController?.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(displayPos.latitude, displayPos.longitude),
//             bearing: _currentBearing,
//             zoom: z,
//             tilt: 50.0,
//           ),
//         ),
//         duration: Duration(milliseconds: animDuration),
//       );

//       if (mounted) setState(() {});
//     } catch (e) {
//       log('❌ Error updating captain position: $e');
//     }
//   }

//   // ==================== ROUTE MANAGEMENT ====================
//   void _onMapCreated(MapLibreMapController c) async {
//     _mapController = c;
//     await _initializeMap();
//   }

//   Future<void> _initializeMap() async {
//     if (widget.trip.driver == null) {
//       log('❌ No driver data');
//       return;
//     }

//     // الموقع الأولي للكابتن
//     final driverLat = double.tryParse(widget.trip.driver?.lat ?? "");
//     final driverLng = double.tryParse(widget.trip.driver?.long ?? "");

//     if (driverLat == null || driverLng == null) {
//       log('⚠️ No initial driver location, using fallback');
//       _mapController?.moveCamera(
//         CameraUpdate.newCameraPosition(
//           const CameraPosition(target: _fallback, zoom: 15),
//         ),
//       );
//     } else {
//       _captainCurrentPos = ll.LatLng(driverLat, driverLng);
//       _mapController?.moveCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(driverLat, driverLng),
//             zoom: 17.0,
//             tilt: 0.0,
//           ),
//         ),
//       );

//       // حمل الطريق من موقع الكابتن للوجهة
//       await _loadRoute(_captainCurrentPos!, _destination);
//     }

//     // بدء التتبع الفعلي
//     _startTracking();
//   }

//   Future<void> _loadRoute(ll.LatLng from, ll.LatLng to) async {
//     if (_isFetchingRoute) return;
//     _isFetchingRoute = true;

//     try {
//       final json = await _navRepo.getRoute(
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
//         log('✅ Route loaded: ${_route.length} points');
//       }
//     } catch (e) {
//       log('❌ Route loading error: $e');
//     } finally {
//       _isFetchingRoute = false;
//     }
//   }

//   List<ll.LatLng> _extractRoutePolyline(Map<String, dynamic> json) {
//     // محاولة التنسيق الأول (GeoJSON)
//     dynamic coords = _deepGet(json, ["routes", 0, "geometry", "coordinates"]);
//     coords ??= _deepGet(json, ["geometry", "coordinates"]);

//     if (coords is List && coords.isNotEmpty) {
//       try {
//         return coords.map<ll.LatLng>((e) {
//           return ll.LatLng((e[1] as num).toDouble(), (e[0] as num).toDouble());
//         }).toList();
//       } catch (_) {}
//     }

//     // محاولة Polyline
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
//         if (cur is List && cur.length > key) {
//           cur = cur[key];
//         } else {
//           return null;
//         }
//       } else {
//         if (cur is Map && cur.containsKey(key)) {
//           cur = cur[key];
//         } else {
//           return null;
//         }
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
//         lineOpacity: 0.8,
//         lineJoin: "round",
//       ),
//     );
//   }

//   double _getMinDistanceToRoute(ll.LatLng p, List<ll.LatLng> poly) {
//     if (poly.isEmpty) return 0.0;
//     double minMeters = double.infinity;
//     for (int i = 0; i < poly.length; i += 5) {
//       final d = const ll.Distance().as(ll.LengthUnit.Meter, p, poly[i]);
//       if (d < minMeters) minMeters = d;
//     }
//     return minMeters;
//   }

//   // ==================== UI ====================
//   Future<void> _openGoogleMaps() async {
//     final url =
//         'https://www.google.com/maps/dir/?api=1&destination=${_destination.latitude},${_destination.longitude}&travelmode=driving';
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     }
//   }

//   void _goBackToHome() {
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // الخريطة
//           MapLibreMap(
//             styleString: _styleUrl,
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: const CameraPosition(
//               target: _fallback,
//               zoom: 15,
//             ),
//             myLocationEnabled: false,
//             compassEnabled: false,
//           ),

//           // معلومات الوجهة (أعلى)
//           Positioned(
//             top: 50,
//             left: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black12, blurRadius: 15),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.mode == UserTrackingMode.toPickup
//                         ? "مكان العميل:"
//                         : "الوجهة:",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _destinationName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 12),
//                   if (widget.trip.driver?.name != null)
//                     Row(
//                       children: [
//                         const Icon(Icons.person, size: 18, color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "السائق: ${widget.trip.driver!.name}",
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black87,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: TextButton.icon(
//                       onPressed: _openGoogleMaps,
//                       icon: const Icon(Icons.map_rounded, color: Colors.blue),
//                       label: const Text(
//                         "عرض في جوجل ماب",
//                         style: TextStyle(color: Colors.blue),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // أيقونة الملاحة (وسط الخريطة)
//           if (_captainCurrentPos != null)
//             IgnorePointer(
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(40),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                       child: Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.75),
//                           shape: BoxShape.circle,
//                           boxShadow: const [
//                             BoxShadow(color: Colors.black12, blurRadius: 15),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.directions_car_rounded,
//                           size: 38,
//                           color: Color(0xFF2E7DFF),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           // عرض السرعة (أسفل يمين)
//           Positioned(
//             bottom: 160,
//             right: 16,
//             child: Container(
//               width: 70,
//               height: 70,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "${_captainSpeedKmh.toStringAsFixed(0)}",
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const Text(
//                     "كم/س",
//                     style: TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // لوحة معلومات الرحلة (أسفل)
//           Positioned(
//             bottom: 20,
//             left: 16,
//             right: 16,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black26, blurRadius: 20),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GestureDetector(
//                     onTap: () => setState(
//                       () => _isInfoPanelExpanded = !_isInfoPanelExpanded,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 16,
//                       ),
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(16),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "معلومات الرحلة",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           AnimatedRotation(
//                             turns: _isInfoPanelExpanded ? 0.5 : 0.0,
//                             duration: const Duration(milliseconds: 300),
//                             child: const Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               color: Colors.grey,
//                               size: 28,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   AnimatedCrossFade(
//                     firstChild: const SizedBox.shrink(),
//                     secondChild: Padding(
//                       padding: const EdgeInsets.only(
//                         left: 20,
//                         right: 20,
//                         bottom: 20,
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Column(
//                                 children: [
//                                   const Icon(
//                                     Icons.access_time_rounded,
//                                     color: Colors.blue,
//                                     size: 32,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     widget.trip.formattedETA,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     "الوقت المتوقع",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Container(
//                                 width: 1,
//                                 height: 80,
//                                 color: Colors.grey[300],
//                               ),
//                               Column(
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on_rounded,
//                                     color: Colors.orange,
//                                     size: 32,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     widget.trip.formattedDriverDistance,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     "مسافة السائق",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           const Divider(),
//                           const SizedBox(height: 16),
//                           SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: ElevatedButton.icon(
//                               onPressed: _goBackToHome,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.redAccent,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 elevation: 0,
//                               ),
//                               icon: const Icon(Icons.home_rounded),
//                               label: const Text(
//                                 "الرجوع للصفحة الرئيسية",
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     crossFadeState: _isInfoPanelExpanded
//                         ? CrossFadeState.showSecond
//                         : CrossFadeState.showFirst,
//                     duration: const Duration(milliseconds: 300),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:developer';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:latlong2/latlong.dart' as ll;
// import 'package:maplibre_gl/maplibre_gl.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// import 'package:waslny/core/api/base_api_consumer.dart';
// import 'package:waslny/core/real-time/realtime_api.dart';
// import 'package:waslny/features/general/navigation/navigation_filters.dart';
// import 'package:waslny/features/general/navigation/navigation_repo.dart';
// import 'package:waslny/features/user/home/data/models/get_home_model.dart';

// import '../../../../injector.dart' as injector;

// enum UserTrackingMode { toDestination }

// class UserTrackingScreen extends StatefulWidget {
//   final TripAndServiceModel trip;
//   final UserTrackingMode mode;

//   const UserTrackingScreen({
//     super.key,
//     required this.trip,
//     this.mode = UserTrackingMode.toDestination,
//   });

//   @override
//   State<UserTrackingScreen> createState() => _UserTrackingScreenState();
// }

// class _UserTrackingScreenState extends State<UserTrackingScreen> {
//   // ==================== Controllers ====================
//   MapLibreMapController? _mapController;
//   late final NavigationRepo _navRepo;
//   late final RealtimeApiClient _realtimeClient;

//   // ==================== Real-time Tracking ====================
//   Timer? _trackingTimer;
//   static const Duration _trackingInterval = Duration(seconds: 3);
//   bool _isTrackingActive = false;

//   // ==================== Route & Position ====================
//   List<ll.LatLng> _route = [];
//   bool _routeReady = false;
//   ll.LatLng? _captainCurrentPos;
//   ll.LatLng? _lastCameraTarget;

//   // ==================== Smoothing ====================
//   final KalmanFilterLatLng _kalman = KalmanFilterLatLng(20.0);
//   double _currentBearing = 0.0;
//   double _captainSpeedKmh = 0.0;

//   // ==================== UI State ====================
//   String _destinationName = "جاري تحديد العنوان...";
//   bool _isInfoPanelExpanded = true;
//   bool _isFetchingRoute = false;
//   int _lastRerouteTime = 0;

//   // ==================== Destination ====================
//   late final ll.LatLng _destination;

//   static const String _styleUrl =
//       'https://tiles.baraddy.com/styles/basic-preview/style.json';
//   static const LatLng _fallback = LatLng(30.0444, 31.2357);

//   @override
//   void initState() {
//     super.initState();

//     _navRepo = NavigationRepo(injector.serviceLocator<BaseApiConsumer>());
//     _realtimeClient = RealtimeApiClient(
//       baseUrl: 'https://realtime.baraddy.com',
//     );

//     WakelockPlus.enable();

//     log('📍 Destination: $_destinationName ($_destination)');
//     log(
//       '👨‍✈️ Captain: ${widget.trip.driver?.name} | internalId=${widget.trip.driver?.captainInternalId}',
//     );
//   }

//   @override
//   void dispose() {
//     _stopTracking();
//     WakelockPlus.disable();
//     _realtimeClient.dispose();
//     super.dispose();
//   }

//   // ==================== REALTIME TRACKING ====================
//   void _startTracking() {
//     if (_isTrackingActive) return;

//     final captainInternalId = widget.trip.driver?.captainInternalId;
//     if (captainInternalId == null) {
//       log('❌ startTracking: captainInternalId is null');
//       return;
//     }

//     log(
//       '🚀 Starting real-time tracking for captainInternalId=$captainInternalId',
//     );
//     _isTrackingActive = true;

//     // (اختياري) عشان أول تحديث ييجي فورًا بدل ما يستنى 3 ثواني
//     _updateCaptainPosition();

//     _trackingTimer = Timer.periodic(_trackingInterval, (_) async {
//       await _updateCaptainPosition();
//     });
//   }

//   void _stopTracking() {
//     _trackingTimer?.cancel();
//     _trackingTimer = null;
//     _isTrackingActive = false;
//     log('⏹️ Tracking stopped');
//   }

//   Future<void> _updateCaptainPosition() async {
//     try {
//       final captainInternalId = widget.trip.driver?.captainInternalId;
//       if (captainInternalId == null) {
//         log('❌ updateCaptainPosition: Missing captainInternalId -> stopping');
//         _stopTracking();
//         return;
//       }

//       log('🔄 Fetching captain location: id=$captainInternalId');

//       final location = await _realtimeClient.getCaptainLocation(
//         captainInternalId: captainInternalId,
//       );

//       log(
//         '✅ API location: lat=${location.latitude}, lng=${location.longitude}, '
//         'accuracy=${location.accuracy}, speed=${location.speed}, heading=${location.heading}',
//       );

//       if (!mounted) return;

//       final nowMs = DateTime.now().millisecondsSinceEpoch;

//       final filtered = _kalman.filter(
//         lat: location.latitude,
//         lng: location.longitude,
//         accuracy: location.accuracy ?? 5.0,
//         timestampMs: nowMs,
//       );

//       log(
//         '🎯 Kalman filtered: lat=${filtered.latitude}, lng=${filtered.longitude}, '
//         'acc=${location.accuracy ?? 5.0}',
//       );

//       // 2️⃣ Off-route reroute check
//       if (_routeReady && !_isFetchingRoute) {
//         final distToRoute = _getMinDistanceToRoute(filtered, _route);
//         log('📏 Distance to route: ${distToRoute.toStringAsFixed(1)}m');

//         if (distToRoute > 45.0 && (nowMs - _lastRerouteTime > 5000)) {
//           log('🔄 Off-route -> rerouting...');
//           _lastRerouteTime = nowMs;
//           _loadRoute(filtered, _destination);
//         }
//       }

//       // 3️⃣ Snap to route
//       ll.LatLng displayPos = filtered;
//       if (_routeReady) {
//         final snapped = RouteSnapper.snapToRoute(
//           filtered,
//           _route,
//           maxSnapMeters: 40,
//         );

//         final snapDist = const ll.Distance().as(
//           ll.LengthUnit.Meter,
//           filtered,
//           snapped,
//         );

//         log('🧲 Snap dist: ${snapDist.toStringAsFixed(1)}m');

//         if (snapDist < 40) {
//           displayPos = snapped;
//           log('✅ Using snapped position');
//         } else {
//           log('⚠️ Using filtered position (snap too far)');
//         }
//       }

//       // 4️⃣ Speed (km/h) smoothing
//       double instantSpeedKmh = (location.speed ?? 0.0) * 3.6;
//       if (instantSpeedKmh < 0) instantSpeedKmh = 0;
//       _captainSpeedKmh = (_captainSpeedKmh * 0.20) + (instantSpeedKmh * 0.80);

//       // 5️⃣ Bearing smoothing
//       double bearing = location.heading ?? _currentBearing;
//       if (_captainSpeedKmh < 5) {
//         bearing = _currentBearing;
//       } else {
//         final diff = (bearing - _currentBearing).abs();
//         if (diff > 180) {
//           _currentBearing = bearing;
//         } else {
//           _currentBearing = (_currentBearing * 0.1) + (bearing * 0.9);
//         }
//       }

//       _captainCurrentPos = displayPos;

//       // 6️⃣ Camera
//       final int animDurationMs = 3000;
//       _lastCameraTarget = displayPos;

//       double zoom = 17.0;
//       if (_captainSpeedKmh > 80)
//         zoom = 15.0;
//       else if (_captainSpeedKmh > 40)
//         zoom = 16.0;

//       log(
//         '📺 Camera -> target=(${displayPos.latitude},${displayPos.longitude}) '
//         'zoom=$zoom bearing=$_currentBearing speed=${_captainSpeedKmh.toStringAsFixed(1)}km/h',
//       );

//       await _mapController?.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(displayPos.latitude, displayPos.longitude),
//             bearing: _currentBearing,
//             zoom: zoom,
//             tilt: 50.0,
//           ),
//         ),
//         duration: Duration(milliseconds: animDurationMs),
//       );

//       if (!mounted) return;
//       setState(() {});
//     } catch (e, st) {
//       log('❌ Error updating captain position: $e');
//       log('🧵 StackTrace: $st');
//     }
//   }

//   // ==================== ROUTE MANAGEMENT ====================
//   void _onMapCreated(MapLibreMapController c) async {
//     _mapController = c;
//     await _initializeMap();
//   }

//   Future<void> _initializeMap() async {
//     if (widget.trip.driver == null) {
//       log('❌ initializeMap: No driver data');
//       return;
//     }

//     log(
//       '🎬 Initializing map: driver=${widget.trip.driver?.name} '
//       'internalId=${widget.trip.driver?.captainInternalId}',
//     );

//     final driverLat = double.tryParse(widget.trip.driver?.lat ?? "");
//     final driverLng = double.tryParse(widget.trip.driver?.long ?? "");

//     log('📍 Initial trip driver position: lat=$driverLat lng=$driverLng');

//     if (driverLat == null || driverLng == null) {
//       log('⚠️ No initial driver location -> using fallback');
//       _mapController?.moveCamera(
//         CameraUpdate.newCameraPosition(
//           const CameraPosition(target: _fallback, zoom: 15),
//         ),
//       );
//     } else {
//       _captainCurrentPos = ll.LatLng(driverLat, driverLng);
//       log('✅ Set initial captain position: $_captainCurrentPos');

//       _mapController?.moveCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(driverLat, driverLng),
//             zoom: 17.0,
//             tilt: 0.0,
//           ),
//         ),
//       );

//       await _loadRoute(_captainCurrentPos!, _destination);
//     }

//     log('🚀 Map ready -> start tracking');
//     _startTracking();
//   }

//   Future<void> _loadRoute(ll.LatLng from, ll.LatLng to) async {
//     if (_isFetchingRoute) return;
//     _isFetchingRoute = true;

//     log('🧭 Loading route from=$from to=$to');

//     try {
//       final json = await _navRepo.getRoute(
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
//         log('✅ Route loaded: ${_route.length} points');
//       } else {
//         log('⚠️ Route decode returned empty polyline');
//       }
//     } catch (e, st) {
//       log('❌ Route loading error: $e');
//       log('🧵 StackTrace: $st');
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
//         if (cur is List && cur.length > key) {
//           cur = cur[key];
//         } else {
//           return null;
//         }
//       } else {
//         if (cur is Map && cur.containsKey(key)) {
//           cur = cur[key];
//         } else {
//           return null;
//         }
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
//         lineOpacity: 0.8,
//         lineJoin: "round",
//       ),
//     );
//   }

//   double _getMinDistanceToRoute(ll.LatLng p, List<ll.LatLng> poly) {
//     if (poly.isEmpty) return 0.0;

//     double minMeters = double.infinity;
//     for (int i = 0; i < poly.length; i += 5) {
//       final d = const ll.Distance().as(ll.LengthUnit.Meter, p, poly[i]);
//       if (d < minMeters) minMeters = d;
//     }
//     return minMeters;
//   }

//   // ==================== UI ====================
//   Future<void> _openGoogleMaps() async {
//     final url =
//         'https://www.google.com/maps/dir/?api=1&destination=${_destination.latitude},${_destination.longitude}&travelmode=driving';
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     }
//   }

//   void _goBackToHome() {
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           MapLibreMap(
//             styleString: _styleUrl,
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: const CameraPosition(
//               target: _fallback,
//               zoom: 15,
//             ),
//             myLocationEnabled: false,
//             compassEnabled: false,
//           ),
//           Positioned(
//             top: 50,
//             left: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black12, blurRadius: 15),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.mode == UserTrackingMode.toPickup
//                         ? "مكان العميل:"
//                         : "الوجهة:",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _destinationName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 12),
//                   if (widget.trip.driver?.name != null)
//                     Row(
//                       children: [
//                         const Icon(Icons.person, size: 18, color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "السائق: ${widget.trip.driver!.name}",
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black87,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: TextButton.icon(
//                       onPressed: _openGoogleMaps,
//                       icon: const Icon(Icons.map_rounded, color: Colors.blue),
//                       label: const Text(
//                         "عرض في جوجل ماب",
//                         style: TextStyle(color: Colors.blue),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (_captainCurrentPos != null)
//             IgnorePointer(
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(40),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                       child: Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.75),
//                           shape: BoxShape.circle,
//                           boxShadow: const [
//                             BoxShadow(color: Colors.black12, blurRadius: 15),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.directions_car_rounded,
//                           size: 38,
//                           color: Color(0xFF2E7DFF),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           Positioned(
//             bottom: 160,
//             right: 16,
//             child: Container(
//               width: 70,
//               height: 70,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     _captainSpeedKmh.toStringAsFixed(0),
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const Text(
//                     "كم/س",
//                     style: TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 16,
//             right: 16,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black26, blurRadius: 20),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GestureDetector(
//                     onTap: () => setState(
//                       () => _isInfoPanelExpanded = !_isInfoPanelExpanded,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 16,
//                       ),
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(16),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "معلومات الرحلة",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           AnimatedRotation(
//                             turns: _isInfoPanelExpanded ? 0.5 : 0.0,
//                             duration: const Duration(milliseconds: 300),
//                             child: const Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               color: Colors.grey,
//                               size: 28,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   AnimatedCrossFade(
//                     firstChild: const SizedBox.shrink(),
//                     secondChild: Padding(
//                       padding: const EdgeInsets.only(
//                         left: 20,
//                         right: 20,
//                         bottom: 20,
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Column(
//                                 children: [
//                                   const Icon(
//                                     Icons.access_time_rounded,
//                                     color: Colors.blue,
//                                     size: 32,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     widget.trip.formattedETA,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     "الوقت المتوقع",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Container(
//                                 width: 1,
//                                 height: 80,
//                                 color: Colors.grey[300],
//                               ),
//                               Column(
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on_rounded,
//                                     color: Colors.orange,
//                                     size: 32,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     widget.trip.formattedDriverDistance,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     "مسافة السائق",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           const Divider(),
//                           const SizedBox(height: 16),
//                           SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: ElevatedButton.icon(
//                               onPressed: _goBackToHome,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.redAccent,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 elevation: 0,
//                               ),
//                               icon: const Icon(Icons.home_rounded),
//                               label: const Text(
//                                 "الرجوع للصفحة الرئيسية",
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     crossFadeState: _isInfoPanelExpanded
//                         ? CrossFadeState.showSecond
//                         : CrossFadeState.showFirst,
//                     duration: const Duration(milliseconds: 300),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:waslny/core/api/base_api_consumer.dart';
import 'package:waslny/core/real-time/realtime_api.dart';
import 'package:waslny/features/general/navigation/navigation_filters.dart';
import 'package:waslny/features/general/navigation/navigation_repo.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

import '../../../../injector.dart' as injector;

enum UserTrackingMode { toPickup, toDestination }

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
  // ==================== Controllers ====================
  MapLibreMapController? _mapController;
  late final NavigationRepo _navRepo;
  late final RealtimeApiClient _realtimeClient;

  // ==================== Style / Symbols ====================
  bool _styleLoaded = false;
  bool _carImageAdded = false;
  Symbol? _captainSymbol;

  static const String _carAssetPath = 'assets/icons/car_icon.png';
  static const String _carIconName = 'car_icon';
  static const double _carIconSize = 1.35;

  // ==================== Real-time Tracking ====================
  Timer? _trackingTimer;
  static const Duration _trackingInterval = Duration(seconds: 3);
  bool _isTrackingActive = false;

  // ==================== Route & Position ====================
  List<ll.LatLng> _route = [];
  bool _routeReady = false;

  ll.LatLng? _captainCurrentPos;
  ll.LatLng? _lastCameraTarget;

  bool _routeRequestedOnceFromRealtime = false;

  // ==================== Smoothing ====================
  final KalmanFilterLatLng _kalman = KalmanFilterLatLng(20.0);
  double _currentBearing = 0.0;
  double _captainSpeedKmh = 0.0;

  // ==================== UI State ====================
  String _destinationName = "جاري تحديد العنوان...";
  bool _isInfoPanelExpanded = true;
  bool _isFetchingRoute = false;
  int _lastRerouteTime = 0;

  // ==================== Destination ====================
  late final ll.LatLng _destination;

  static const String _styleUrl =
      'https://tiles.baraddy.com/styles/basic-preview/style.json';
  static const LatLng _fallback = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();

    log('🧭 UserTrackingScreen initState fired'); // لازم يظهر لو الصفحة شغّالة

    _navRepo = NavigationRepo(injector.serviceLocator<BaseApiConsumer>());
    _realtimeClient = RealtimeApiClient(
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
    log('👨‍✈️ Captain internalId=${widget.trip.driver?.captainInternalId}');
  }

  @override
  void dispose() {
    _stopTracking();
    WakelockPlus.disable();
    _realtimeClient.dispose();
    super.dispose();
  }

  // ==================== STYLE HELPERS ====================
  Future<void> _ensureCarIconAdded() async {
    if (_mapController == null) return;
    if (!_styleLoaded) return;
    if (_carImageAdded) return;

    final ByteData bytes = await rootBundle.load(_carAssetPath);
    final Uint8List list = bytes.buffer.asUint8List();

    await _mapController!.addImage(_carIconName, list);
    _carImageAdded = true;

    log(
      '🖼️ addImage done: name=$_carIconName path=$_carAssetPath bytes=${list.length}',
    );
  }

  Future<void> _upsertCaptainMarker(ll.LatLng pos) async {
    final c = _mapController;
    if (c == null) return;

    if (!_styleLoaded) {
      log('⚠️ upsert marker skipped: style not loaded yet');
      return;
    }

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
      log('✅ Captain symbol created');
    } else {
      await c.updateSymbol(
        _captainSymbol!,
        SymbolOptions(geometry: geo, iconRotate: _currentBearing),
      );
    }
  }

  Future<void> _afterStyleReady() async {
    if (!mounted) return;

    await _ensureCarIconAdded();

    if (_routeReady && _route.isNotEmpty) {
      await _drawRoute();
    }

    if (_captainCurrentPos != null) {
      await _upsertCaptainMarker(_captainCurrentPos!);
    }

    if (mounted) setState(() {});
  }

  // ==================== REALTIME TRACKING ====================
  void _startTracking() {
    if (_isTrackingActive) return;

    // ✅ استخدم driverId بدلاً من captainInternalId
    final driverId = widget.trip.driver?.id;
    if (driverId == null) {
      log('❌ startTracking: driverId is null');
      return;
    }

    _isTrackingActive = true;
    log('🚀 Tracking started for driverId=$driverId');

    _updateCaptainPosition();

    _trackingTimer = Timer.periodic(_trackingInterval, (_) async {
      await _updateCaptainPosition();
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTrackingActive = false;
    log('⏹️ Tracking stopped');
  }

  Future<void> _updateCaptainPosition() async {
    try {
      final driverId = widget.trip.driver?.id;
      if (driverId == null) {
        log('❌ updateCaptainPosition: Missing driverId -> stopping');
        _stopTracking();
        return;
      }

      final currentLat = _captainCurrentPos?.latitude ?? _destination.latitude;
      final currentLng =
          _captainCurrentPos?.longitude ?? _destination.longitude;

      log(
        '🔍 Searching nearest captains around ($currentLat, $currentLng) for driver=$driverId',
      );

      final nearest = await _realtimeClient.getNearestCaptain(
        lat: currentLat,
        lng: currentLng,
        radius: 10000,
      );

      if (nearest.success && nearest.nearest != null) {
        final candidate = nearest.nearest!;

        if (candidate.phone == widget.trip.driver?.phone) {
          log(
            '✅ Found exact driver! lat=${candidate.latitude} lng=${candidate.longitude} dist=${candidate.distanceMeters}m',
          );

          final nowMs = DateTime.now().millisecondsSinceEpoch;
          final filtered = _kalman.filter(
            lat: candidate.latitude,
            lng: candidate.longitude,
            accuracy: 15.0,
            timestampMs: nowMs,
          );

          ll.LatLng displayPos = filtered;

          if (!_routeRequestedOnceFromRealtime) {
            _routeRequestedOnceFromRealtime = true;
            log('🧭 First location from nearest -> requesting route');
            _loadRoute(displayPos, _destination);
          }

          _captainSpeedKmh = 25.0;
          _currentBearing = _currentBearing.clamp(0, 360);

          _captainCurrentPos = displayPos;
          await _upsertCaptainMarker(displayPos);

          final movedMeters = _lastCameraTarget == null
              ? 999999.0
              : const ll.Distance().as(
                  ll.LengthUnit.Meter,
                  _lastCameraTarget!,
                  displayPos,
                );

          if (movedMeters >= 3) {
            _lastCameraTarget = displayPos;
            final zoom = _captainSpeedKmh > 40 ? 16.0 : 17.0;
            await _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(displayPos.latitude, displayPos.longitude),
                  bearing: _currentBearing,
                  zoom: zoom,
                  tilt: 50.0,
                ),
              ),
              duration: const Duration(milliseconds: 900),
            );
          }

          if (!mounted) return;
          setState(() {});
          return;
        } else {
          log(
            '⚠️ Nearest phone=${candidate.phone} != expected ${widget.trip.driver?.phone}',
          );
        }
      }

      log('❌ No matching captain found');

      // ✅ Fallback: استخدم fromLat/fromLong (السواق قريب من from)
      final fallbackLat = double.tryParse(widget.trip.fromLat ?? "");
      final fallbackLng = double.tryParse(widget.trip.fromLong ?? "");
      if (fallbackLat != null && fallbackLng != null) {
        log('📍 Fallback to from position: ($fallbackLat, $fallbackLng)');
        final fallbackPos = ll.LatLng(fallbackLat, fallbackLng);
        _captainCurrentPos = fallbackPos;
        await _upsertCaptainMarker(fallbackPos);
      } else {
        log('⚠️ No fallback position available');
      }
    } catch (e, st) {
      log('❌ updateCaptainPosition error: $e');
      log('🧵 $st');
    }
  }

  // ==================== ROUTE MANAGEMENT ====================
  void _onMapCreated(MapLibreMapController c) async {
    _mapController = c;
    log('🗺️ onMapCreated fired');

    // Fallback: لو styleLoaded ما اتناداش
    Future.delayed(const Duration(milliseconds: 900), () async {
      if (!mounted) return;
      if (!_styleLoaded) {
        _styleLoaded = true;
        log('⚠️ Style fallback triggered');
        await _afterStyleReady();
      }
    });

    await _initializeMap();
  }

  Future<void> _initializeMap() async {
    // حاول تستخدم driver.lat/long لو موجودين (اختياري)
    final driverLat = double.tryParse(widget.trip.driver?.lat ?? "");
    final driverLng = double.tryParse(widget.trip.driver?.long ?? "");

    log('📍 Initial driverLat=$driverLat driverLng=$driverLng');

    if (driverLat != null && driverLng != null) {
      _captainCurrentPos = ll.LatLng(driverLat, driverLng);

      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(driverLat, driverLng),
            zoom: 17.0,
            tilt: 0.0,
          ),
        ),
      );

      // route من الـ initial pos (لو تحب)
      _loadRoute(_captainCurrentPos!, _destination);
    } else {
      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(target: _fallback, zoom: 15),
        ),
      );
    }

    _startTracking();
  }

  Future<void> _loadRoute(ll.LatLng from, ll.LatLng to) async {
    if (_isFetchingRoute) return;
    _isFetchingRoute = true;

    log('🧭 Loading route from=$from to=$to');

    try {
      final json = await _navRepo.getRoute(
        fromLat: from.latitude,
        fromLng: from.longitude,
        toLat: to.latitude,
        toLng: to.longitude,
      );

      final decoded = _extractRoutePolyline(json);

      log('🧩 decoded points: ${decoded.length}');
      if (decoded.isNotEmpty) {
        log('🧩 first=${decoded.first} last=${decoded.last}');
      }

      if (decoded.isNotEmpty) {
        _route = decoded;
        _routeReady = true;

        if (_styleLoaded) {
          await _drawRoute();
        }

        if (mounted) setState(() {});
      }
    } catch (e, st) {
      log('❌ loadRoute error: $e');
      log('🧵 $st');
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
    if (!_styleLoaded) {
      log('⚠️ drawRoute skipped: style not loaded');
      return;
    }
    if (_mapController == null || _route.isEmpty) return;

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

    log('✅ drawRoute done: points=${_route.length}');
  }

  double _getMinDistanceToRoute(ll.LatLng p, List<ll.LatLng> poly) {
    if (poly.isEmpty) return 0.0;

    double minMeters = double.infinity;
    for (int i = 0; i < poly.length; i += 5) {
      final d = const ll.Distance().as(ll.LengthUnit.Meter, p, poly[i]);
      if (d < minMeters) minMeters = d;
    }
    return minMeters;
  }

  // ==================== UI ====================
  Future<void> _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${_destination.latitude},${_destination.longitude}&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _goBackToHome() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _styleUrl,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: () async {
              _styleLoaded = true;
              log('🎨 Style loaded callback fired');
              await _afterStyleReady();
            },
            initialCameraPosition: const CameraPosition(
              target: _fallback,
              zoom: 15,
            ),
            myLocationEnabled: false,
            compassEnabled: false,
          ),

          // لوحة معلومات الرحلة (أسفل)
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
                          // ✅ معلومات الوجهة + السائق (اللي عايزهم)
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
                              const SizedBox(height: 16),
                            ],
                          ),

                          // مسافة + وقت (اللي موجودين)
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
                                    widget.trip.formattedETA,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
                                    widget.trip.formattedDriverDistance,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "مسافة السائق",
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
    );
  }
}
