// import 'dart:developer';

// import 'package:waslny/core/real-time/realtime_api.dart';

// class RealtimeService {
//   final RealtimeApiClient _apiClient;

//   RealtimeService({RealtimeApiClient? apiClient})
//     : _apiClient = apiClient ?? RealtimeApiClient();

//   /// ===========================
//   /// تحديث موقع الكابتن الحالي
//   /// ===========================
//   Future<bool> updateLocation({
//     required String internalId,
//     required double lat,
//     required double lng,
//     double? accuracy,
//     double? heading,
//     double? speed,
//   }) async {
//     try {
//       log('📍 Updating captain location: $internalId at ($lat, $lng)');

//       final res = await _apiClient.updateCaptainLocation(
//         captainInternalId: internalId,
//         latitude: lat,
//         longitude: lng,
//         accuracy: accuracy,
//         heading: heading,
//         speed: speed,
//       );

//       log('✅ Location updated: ${res.success}');
//       return res.success;
//     } catch (e) {
//       log('❌ Error updating location: $e');
//       return false;
//     }
//   }

//   /// ===========================
//   /// البحث عن أقرب كابتن ضمن نصف قطر محدد (default 10km)
//   /// ===========================
//   Future<NearestCaptain?> getNearestCaptain({
//     required double lat,
//     required double lng,
//     int radiusMeters = 10000, // 10 km
//   }) async {
//     try {
//       log('🔍 Searching for nearest captain...');
//       log('📍 Location: lat=$lat, lng=$lng');
//       log('📏 Radius: ${(radiusMeters / 1000).toStringAsFixed(1)}km');

//       final res = await _apiClient.getNearestCaptain(
//         lat: lat,
//         lng: lng,
//         radius: radiusMeters,
//       );

//       log('📊 API Response received:');
//       log('   success: ${res.success}');
//       log('   count: ${res.count}');
//       log('   nearest: ${res.nearest}');

//       if (res.success && res.nearest != null) {
//         log('✅ Captain found: ${res.nearest!.name}');
//         log('   Distance: ${res.nearest!.distanceMeters}m');
//         log('   Status: ${res.nearest!.status}');

//         // optional: نتأكد إن المسافة فعلاً أقل من 10km
//         if (res.nearest!.distanceMeters <= radiusMeters) {
//           log('✅ Captain is within range');
//           return res.nearest!;
//         } else {
//           log(
//             '⚠️ Captain beyond range: ${res.nearest!.distanceMeters}m > $radiusMeters',
//           );
//           return null;
//         }
//       } else {
//         log('❌ No captain found in response');
//         return null;
//       }
//     } catch (e) {
//       log('❌ Error fetching nearest captain: $e');
//       return null;
//     }
//   }

//   /// ===========================
//   /// إغلاق العميل عند عدم الحاجة
//   /// ===========================
//   void dispose() {
//     log('🔌 Disposing RealtimeService');
//     _apiClient.dispose();
//   }
// }

import 'dart:developer';

import 'package:waslny/core/real-time/realtime_api.dart';

class RealtimeService {
  final RealtimeApiClient _apiClient;

  RealtimeService({RealtimeApiClient? apiClient})
    : _apiClient = apiClient ?? RealtimeApiClient();

  /// ===========================
  /// تحديث موقع الكابتن الحالي
  /// ===========================
  Future<bool> updateLocation({
    required String internalId,
    required double lat,
    required double lng,
    double? accuracy,
    double? heading,
    double? speed,
  }) async {
    try {
      log('📍 Updating captain location: $internalId at ($lat, $lng)');

      final res = await _apiClient.updateCaptainLocation(
        captainInternalId: internalId,
        latitude: lat,
        longitude: lng,
        accuracy: accuracy,
        heading: heading,
        speed: speed,
      );

      log('✅ Location updated: ${res.success}');
      return res.success;
    } catch (e) {
      log('❌ Error updating location: $e');
      return false;
    }
  }

  /// ===========================
  /// البحث عن أقرب كابتن ضمن نصف قطر محدد (default 10km)
  /// ===========================
  Future<NearestCaptain?> getNearestCaptain({
    required double lat,
    required double lng,
    int radiusMeters = 10000, // 10 km
  }) async {
    try {
      log('🔍 Searching for nearest captain...');
      log('📍 Location: lat=$lat, lng=$lng');
      log('📏 Radius: ${(radiusMeters / 1000).toStringAsFixed(1)}km');

      final res = await _apiClient.getNearestCaptain(
        lat: lat,
        lng: lng,
        radius: radiusMeters,
      );

      log('📊 API Response received:');
      log('   success: ${res.success}');
      log('   count: ${res.count}');
      log('   nearest: ${res.nearest}');

      if (res.success && res.nearest != null) {
        log('✅ Captain found: ${res.nearest!.name}');
        log('   Distance: ${res.nearest!.distanceMeters}m');
        log('   Status: ${res.nearest!.status}');

        // optional: نتأكد إن المسافة فعلاً أقل من 10km
        if (res.nearest!.distanceMeters <= radiusMeters) {
          log('✅ Captain is within range');
          return res.nearest!;
        } else {
          log(
            '⚠️ Captain beyond range: ${res.nearest!.distanceMeters}m > $radiusMeters',
          );
          return null;
        }
      } else {
        log('❌ No captain found in response');
        return null;
      }
    } catch (e) {
      log('❌ Error fetching nearest captain: $e');
      return null;
    }
  }

  /// ===========================
  /// إغلاق العميل عند عدم الحاجة
  /// ===========================
  void dispose() {
    log('🔌 Disposing RealtimeService');
    _apiClient.dispose();
  }
}
