// import 'dart:async';
// import 'dart:developer';
// import 'dart:ui';
// import 'package:waslny/core/exports.dart';
// import 'package:waslny/core/preferences/preferences.dart';
// import 'package:waslny/features/general/location/data/models/get_address_map_model.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BackgroundLocationService {
//   static const String serviceName = "location_tracker";

//   // Stream للاستماع لتحديثات الموقع من الـ UI
//   static StreamController<Map<String, dynamic>> _locationController =
//       StreamController<Map<String, dynamic>>.broadcast();

//   static Stream<Map<String, dynamic>> get onLocationUpdate =>
//       _locationController.stream;

//   /// بدء الخدمة
//   static Future<bool> startService() async {
//     final service = FlutterBackgroundService();
//     bool isRunning = await service.isRunning();

//     if (!isRunning) {
//       return await service.startService();
//     }
//     return true;
//   }

//   /// إيقاف الخدمة
//   static Future<bool> stopService() async {
//     final service = FlutterBackgroundService();
//     bool isRunning = await service.isRunning();
//     if (isRunning) {
//       service.invoke("stop");
//       return true;
//     }
//     return true;
//   }

//   /// التحقق من حالة الخدمة
//   static Future<bool> isServiceRunning() async {
//     final service = FlutterBackgroundService();
//     return await service.isRunning();
//   }
// }

// /// تهيئة الخدمة
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: false,
//       isForegroundMode: true,
//       notificationChannelId: 'location_tracker_channel',
//       initialNotificationTitle: 'Location Tracker',
//       initialNotificationContent: 'Initializing...',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: false,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
// }

// /// للـ iOS Background
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.reload();
//   final log = preferences.getStringList('log') ?? <String>[];
//   log.add(DateTime.now().toIso8601String());
//   await preferences.setStringList('log', log);
//   return true;
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//   print("🚀 Background service started");
//   Timer? mainTimer;
//   Timer? retryTimer;
//   bool isRetryMode = false;
//   int retryAttempts = 0;
//   const int maxRetryAttempts = 5;
//   late void Function() startRetryTimer;

//   // 1. دالة محاولة التحديث
//   Future<bool> _attemptLocationUpdate(ServiceInstance service,
//       bool currentRetryMode, int currentRetryAttempts) async {
//     bool success = await _performLocationUpdate(service);
//     if (!success && !currentRetryMode) {
//       isRetryMode = true;
//       retryAttempts = 1;
//       startRetryTimer(); // نقدر نستدعيها دلوقتي لأننا عرفناها بـ late
//       print("🔄 Starting retry mode due to failed request");
//     }
//     return success;
//   }

//   // 2. نكمل تعريف دالة startRetryTimer بعد ما خلّيناها late
//   startRetryTimer = () {
//     retryTimer?.cancel();
//     retryTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
//       if (isRetryMode && retryAttempts < maxRetryAttempts) {
//         bool success =
//             await _attemptLocationUpdate(service, isRetryMode, retryAttempts);
//         if (success) {
//           isRetryMode = false;
//           retryAttempts = 0;
//           retryTimer?.cancel();
//           print("✅ Retry successful - Returning to normal schedule");
//         } else {
//           retryAttempts++;
//           print("❌ Retry attempt $retryAttempts failed");
//           if (retryAttempts >= maxRetryAttempts) {
//             print(
//                 "🛑 Max retry attempts reached - Waiting for next main cycle");
//             isRetryMode = false;
//             retryAttempts = 0;
//             retryTimer?.cancel();
//           }
//         }
//       }
//     });
//   };
//   // 3. مؤقت التحديث الرئيسي
//   Future<void> startMainTimer() async {
//     mainTimer?.cancel();
//     int hours = await  _getHors();
//     mainTimer = Timer.periodic( Duration(hours:hours), (timer) async {
//       if (!isRetryMode) {
//         await _attemptLocationUpdate(service, isRetryMode, retryAttempts);
//       }
//     });
//   }
//    // إعداد Android Notification
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//     service.setForegroundNotificationInfo(
//       title: "Location Tracker",
//       content: "Service started successfully",
//     );
//   }
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//   // تشغيل المؤقت الأساسي وأول محاولة
//   startMainTimer();
//   await _attemptLocationUpdate(service, isRetryMode, retryAttempts);
//   service.on('stop').listen((event) {
//     print("🛑 Stopping background service");
//     mainTimer?.cancel();
//     retryTimer?.cancel();
//     service.stopSelf();
//   });
// }
// Future<bool> _performLocationUpdate(ServiceInstance service) async {
//   try {
//     print("📍 Performing location update...");

//     if (service is AndroidServiceInstance) {
//       service.setForegroundNotificationInfo(
//         title: "Location Tracker",
//         content:
//             "Getting location... ${DateTime.now().toString().substring(11, 19)}",
//       );
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       print("❌ Location permission denied");
//       _updateNotification(service, "Permission denied", isError: true);
//       return false;
//     }

//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print("❌ Location service disabled");

//       _updateNotification(service, "GPS disabled", isError: true);

//       String token = await _getToken() ?? '';

//       bool sent = await _sendLocationToServer(
//         locationEn: "GPS disabled",
//         locationAr: "معطل الgps",
//         token: token,
//         isDisabled: true,
//       );

//       service.invoke('update', {
//         'timestamp': DateTime.now().toString().substring(11, 19),
//         'status': sent ? 'gps_disabled_reported' : 'gps_disabled_failed',
//         'message': 'GPS disabled - Status sent to server'
//       });

//       return true; // نكمل التايمر العادي بدون Retry
//     }

//     Position? position;
//     try {
//       position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 30),
//       );
//       print("📍 Location: ${position.latitude}, ${position.longitude}");
//     } catch (e) {
//       print("❌ Failed to get location: $e");
//       _updateNotification(service, "Failed to get location", isError: true);
//       return false;
//     }

//     String locationAr =
//         await _getFormattedAddress(position.latitude, position.longitude, "ar");
//     String locationEn =
//         await _getFormattedAddress(position.latitude, position.longitude, "en");

//     String token = await _getToken() ?? '';
//     bool success = await _sendLocationToServer(
//       locationAr: locationAr,
//       locationEn: locationEn,
//       lat: position.latitude,
//       lng: position.longitude,
//       token: token,
//     );

//     String timestamp = DateTime.now().toString().substring(11, 19);

//     if (success) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('last_location_update', timestamp);
//       await prefs.setDouble('last_lat', position.latitude);
//       await prefs.setDouble('last_lng', position.longitude);
//       await prefs.setString(
//           'last_successful_update', DateTime.now().toIso8601String());

//       _updateNotification(service, "Updated at $timestamp");
//       print("✅ Location updated successfully");

//       service.invoke('update', {
//         'lat': position.latitude,
//         'lng': position.longitude,
//         'timestamp': timestamp,
//         'status': 'success'
//       });

//       return true;
//     } else {
//       _updateNotification(service, "Server error - Will retry", isError: true);
//       print("❌ Server error - Will retry in 5 minutes");

//       service.invoke('update', {
//         'timestamp': timestamp,
//         'status': 'error',
//         'message': 'Server error - Will retry'
//       });

//       return false;
//     }
//   } catch (e, stackTrace) {
//     print("❌ Location update failed: $e");
//     print("Stack trace: $stackTrace");

//     _updateNotification(service, "Update failed - Will retry", isError: true);

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('last_background_error', e.toString());
//     await prefs.setString(
//         'last_background_error_time', DateTime.now().toIso8601String());

//     service.invoke('update', {
//       'timestamp': DateTime.now().toString().substring(11, 19),
//       'status': 'error',
//       'message': 'Update failed - Will retry'
//     });

//     return false;
//   }
// }

// /// تحديث الإشعار
// void _updateNotification(ServiceInstance service, String message,
//     {bool isError = false}) {
//   if (service is AndroidServiceInstance) {
//     service.setForegroundNotificationInfo(
//       title: "Location Tracker",
//       content: message,
//     );
//   }
// }

// Future<String?> _getToken() async {
//   AndroidOptions getAndroidOptions() =>
//       const AndroidOptions(encryptedSharedPreferences: true);
//   IOSOptions getIOSOptions() =>
//       const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

//   prefs = await SharedPreferences.getInstance();

//   secureStorage = FlutterSecureStorage(
//       aOptions: getAndroidOptions(), iOptions: getIOSOptions());
//   final userModel = await Preferences.instance.getUserModel();

//   if (userModel.data != null) {
//     return userModel.data?.token;
//   } else {
//     return null;
//   }
// }
// Future<int> _getHors () async  {
  
//   prefs = await SharedPreferences.getInstance();

 
//   final hours  = await Preferences.instance.getLocationHours();
//   log("⏰ Location update interval: $hours hours");
//   return int.tryParse(hours) ?? 3;
  
// }

// // /// إرسال الموقع للسيرفر
// // Future<bool> _sendLocationToServer(double lat, double lng, String token) async {
// //   try {
// //     final url = Uri.parse('${BackgroundLocationService.BASE_URL}${BackgroundLocationService.UPDATE_LOCATION_ENDPOINT}');

// //     final response = await http.post(
// //       url,
// //       headers: {
// //         'Content-Type': 'application/json',
// //         'Authorization': token,
// //       },
// //       body: jsonEncode({
// //         "shipment_id": 22,
// //         "location": "Lat: $lat, Lng: $lng",
// //         "key": "addShipmentLocation"
// //       }),
// //     ).timeout(const Duration(seconds: 30));

// //     print("📡 Server response: ${response.statusCode}");

// //     if (response.statusCode >= 200 && response.statusCode < 300) {
// //       print("✅ Location sent successfully");
// //       return true;
// //     } else {
// //       print("❌ Server error: ${response.statusCode} - ${response.body}");
// //       return false;
// //     }

// //   } catch (e) {
// //     print("❌ Network error: $e");
// //     return false;
// //   }
// // }
// Future<bool> _sendLocationToServer(
//     {required String locationAr,
//     required String locationEn,
//     double? lat,
//     double? lng,
//     required String token,
//     bool isDisabled = false}) async {
//   try {
//     final dio = Dio();
//     log("locationAr ====>> $locationAr");
//     log("locationEn ====>> $locationEn");
//     log("lat ====>> $lat");
//     log("lng ====>> $lng");
//     log("token ====>> $token");
//     log("isDisabled ====>> $isDisabled");

//     final response = await dio.post(
//       EndPoints.addShipmentLocationUrl,
//       options: Options(
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': token,
//         },
//         sendTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//       ),
//       data: {
//         "is_disabled": isDisabled ? 1 : 0,
//         "location": {"ar": locationAr, "en": locationEn},
//         if (lat != null) "lat": lat,
//         if (lng != null) "long": lng,
//         "key": "addShipmentLocation"
//       },
//     );
//     print("data set ${{
//       "is_disabled": isDisabled ? 1 : 0,
//       "location": {"ar": locationAr, "en": locationEn},
//       if (lat != null) "lat": lat,
//       if (lng != null) "long": lng,
//       "key": "addShipmentLocation"
//     }}");
//     print("📡 Server response: ${response.statusCode}");
//     print("📡 Server response: ${response.data.toString()}");

//     if (response.statusCode != null &&
//         response.statusCode! >= 200 &&
//         response.statusCode! < 300 &&
//         response.data is Map<String, dynamic> &&
//         response.data.containsKey('status') &&
//         response.data['status'] >= 200 &&
//         response.data['status'] < 300) {
//       print("✅ Location sent successfully");
//       return true;
//     } else {
//       print("❌ Server error: ${response.statusCode} - ${response.data}");
//       return false;
//     }
//   } catch (e) {
//     print("❌ Dio error: $e");
//     return false;
//   }
// }

// Future<String> _getFormattedAddress(
//     double latitude, double longitude, String language) async {
//   try {
//     final dio = Dio();
//     final response = await dio.get(
//       EndPoints.getAddressMapUrl,
//       queryParameters: {
//         'format': 'json',
//         'lat': latitude,
//         'lon': longitude,
//       },
//       options: Options(
//         headers: {
//           'User-Agent': 'com.octobus.waslny',
//           'Accept-Language': language,
//         },
//       ),
//     );
//     if (response.statusCode != null &&
//         response.statusCode! >= 200 &&
//         response.statusCode! < 300) {
//       print("📡 Address response: ${response.data}");
//       final addressModel = GetAddressMapModel.fromJson(response.data);
//       return addressModel.displayName ?? 'Unknown location';
//     } else {
//       print("❌ Address error: ${response.statusCode} - ${response.data}");
//       return 'Unknown location';
//     }
//   } catch (e) {
//     print('❌ Exception: $e');
//   }

//   return 'Unknown location';
// }
