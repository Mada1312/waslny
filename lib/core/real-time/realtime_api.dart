// import 'dart:async';
// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// /// =======================
// /// Parsing helpers (safe)
// /// =======================
// double? _toNullableDouble(dynamic v) {
//   if (v == null) return null;
//   if (v is num) return v.toDouble();
//   return double.tryParse(v.toString());
// }

// double _toDouble(dynamic v, {double defaultValue = 0.0}) {
//   return _toNullableDouble(v) ?? defaultValue;
// }

// int? _toNullableInt(dynamic v) {
//   if (v == null) return null;
//   if (v is num) return v.toInt();
//   return int.tryParse(v.toString());
// }

// int _toInt(dynamic v, {int defaultValue = 0}) {
//   return _toNullableInt(v) ?? defaultValue;
// }

// DateTime? _tryParseDate(dynamic v) {
//   if (v == null) return null;
//   return DateTime.tryParse(v.toString());
// }

// String _toStringSafe(dynamic v, {String defaultValue = ''}) {
//   if (v == null) return defaultValue;
//   return v.toString();
// }

// /// =======================
// /// Error model
// /// =======================
// class ApiException implements Exception {
//   final int? statusCode;
//   final String message;
//   final dynamic raw;

//   ApiException({required this.message, this.statusCode, this.raw});

//   @override
//   String toString() =>
//       'ApiException(statusCode: $statusCode, message: $message)';
// }

// /// =======================
// /// Models
// /// =======================
// class HealthResponse {
//   final String status;
//   final DateTime? timestamp;
//   final String environment;

//   HealthResponse({
//     required this.status,
//     required this.timestamp,
//     required this.environment,
//   });

//   factory HealthResponse.fromJson(Map<String, dynamic> json) {
//     return HealthResponse(
//       status: _toStringSafe(json['status']),
//       timestamp: _tryParseDate(json['timestamp']),
//       environment: _toStringSafe(json['environment']),
//     );
//   }
// }

// class Captain {
//   final String id;
//   final String phone;
//   final String internalId;
//   final String name;
//   final String vehicleType;
//   final String status;
//   final String rating;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final int? driverId;

//   Captain({
//     required this.id,
//     required this.phone,
//     required this.internalId,
//     required this.name,
//     required this.vehicleType,
//     required this.status,
//     required this.rating,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.driverId,
//   });

//   factory Captain.fromJson(Map<String, dynamic> json) {
//     return Captain(
//       id: _toStringSafe(json['id']),
//       phone: _toStringSafe(json['phone']),
//       internalId: _toStringSafe(json['internal_id']),
//       name: _toStringSafe(json['name']),
//       vehicleType: _toStringSafe(json['vehicle_type']),
//       status: _toStringSafe(json['status']),
//       rating: _toStringSafe(json['rating']),
//       createdAt: _tryParseDate(json['created_at']),
//       updatedAt: _tryParseDate(json['updated_at']),
//       driverId: _toNullableInt(json['driver_id']),
//     );
//   }
// }

// class Shift {
//   final String id;
//   final String captainId;
//   final DateTime? startTime;
//   final DateTime? endTime;
//   final int? durationMinutes;
//   final String status;
//   final String earnings;
//   final DateTime? createdAt;
//   final String shiftType;
//   final DateTime? shiftDate;

//   Shift({
//     required this.id,
//     required this.captainId,
//     required this.startTime,
//     required this.endTime,
//     required this.durationMinutes,
//     required this.status,
//     required this.earnings,
//     required this.createdAt,
//     required this.shiftType,
//     required this.shiftDate,
//   });

//   factory Shift.fromJson(Map<String, dynamic> json) {
//     return Shift(
//       id: _toStringSafe(json['id']),
//       captainId: _toStringSafe(json['captain_id']),
//       startTime: _tryParseDate(json['start_time']),
//       endTime: _tryParseDate(json['end_time']),
//       durationMinutes: _toNullableInt(json['duration_minutes']),
//       status: _toStringSafe(json['status']),
//       earnings: _toStringSafe(json['earnings']),
//       createdAt: _tryParseDate(json['created_at']),
//       shiftType: _toStringSafe(json['shift_type']),
//       shiftDate: _tryParseDate(json['shift_date']),
//     );
//   }
// }

// class RegisterCaptainResponse {
//   final bool success;
//   final String? error;
//   final String? code;
//   final String? internalId;
//   final Captain? captain;
//   final Shift? shift;

//   RegisterCaptainResponse({
//     required this.success,
//     required this.error,
//     required this.code,
//     required this.internalId,
//     required this.captain,
//     required this.shift,
//   });

//   factory RegisterCaptainResponse.fromJson(Map<String, dynamic> json) {
//     final data = json['data'];
//     final dataMap = data is Map<String, dynamic> ? data : null;

//     return RegisterCaptainResponse(
//       success: json['success'] == true,
//       error: json['error']?.toString() ?? json['message']?.toString(),
//       code: json['code']?.toString(),
//       internalId: dataMap?['internal_id']?.toString(),
//       captain: (dataMap?['captain'] is Map<String, dynamic>)
//           ? Captain.fromJson(dataMap!['captain'] as Map<String, dynamic>)
//           : null,
//       shift: (dataMap?['shift'] is Map<String, dynamic>)
//           ? Shift.fromJson(dataMap!['shift'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }

// class UpdateLocationResponse {
//   final bool success;
//   final CaptainLocation? location;
//   final String? error;

//   UpdateLocationResponse({
//     required this.success,
//     required this.location,
//     required this.error,
//   });

//   factory UpdateLocationResponse.fromJson(Map<String, dynamic> json) {
//     return UpdateLocationResponse(
//       success: json['success'] == true,
//       location: json['location'] == null
//           ? null
//           : CaptainLocation.fromJson(json['location'] as Map<String, dynamic>),
//       error: json['error']?.toString(),
//     );
//   }
// }

// class CaptainLocation {
//   final String id;
//   final String captainId;
//   final double latitude;
//   final double longitude;
//   final double? accuracy;
//   final double? heading;
//   final double? speed;
//   final DateTime? timestamp;
//   final String? locationGeom;

//   CaptainLocation({
//     required this.id,
//     required this.captainId,
//     required this.latitude,
//     required this.longitude,
//     required this.accuracy,
//     required this.heading,
//     required this.speed,
//     required this.timestamp,
//     required this.locationGeom,
//   });

//   factory CaptainLocation.fromJson(Map<String, dynamic> json) {
//     return CaptainLocation(
//       id: _toStringSafe(json['id']),
//       captainId: _toStringSafe(json['captain_id']),
//       latitude: _toDouble(json['latitude']),
//       longitude: _toDouble(json['longitude']),
//       accuracy: _toNullableDouble(json['accuracy']),
//       heading: _toNullableDouble(json['heading']),
//       speed: _toNullableDouble(json['speed']),
//       timestamp: _tryParseDate(json['timestamp']),
//       locationGeom:
//           json['location_geom']?.toString() ??
//           json['locationGeom']?.toString() ??
//           json['location']?.toString(),
//     );
//   }
// }

// class NearestResponse {
//   final bool success;
//   final NearestCaptain? nearest;
//   final int count;
//   final String? error;

//   NearestResponse({
//     required this.success,
//     required this.nearest,
//     required this.count,
//     required this.error,
//   });

//   factory NearestResponse.fromJson(Map<String, dynamic> json) {
//     final n = json['nearest'];
//     return NearestResponse(
//       success: json['success'] == true,
//       nearest: (n is Map<String, dynamic>) ? NearestCaptain.fromJson(n) : null,
//       count: _toInt(json['count']),
//       error: json['error']?.toString(),
//     );
//   }
// }

// class NearestCaptain {
//   final String internalId;
//   final String phone;
//   final String name;
//   final String vehicleType;
//   final String status;

//   final String? shiftId;
//   final String? shiftType;
//   final DateTime? shiftDate;
//   final DateTime? startTime;

//   final double latitude;
//   final double longitude;
//   final DateTime? timestamp;
//   final int distanceMeters;

//   NearestCaptain({
//     required this.internalId,
//     required this.phone,
//     required this.name,
//     required this.vehicleType,
//     required this.status,
//     required this.shiftId,
//     required this.shiftType,
//     required this.shiftDate,
//     required this.startTime,
//     required this.latitude,
//     required this.longitude,
//     required this.timestamp,
//     required this.distanceMeters,
//   });

//   factory NearestCaptain.fromJson(Map<String, dynamic> json) {
//     return NearestCaptain(
//       internalId: _toStringSafe(json['internal_id']),
//       phone: _toStringSafe(json['phone']),
//       name: _toStringSafe(json['name']),
//       vehicleType: _toStringSafe(json['vehicle_type']),
//       status: _toStringSafe(json['status']),
//       shiftId: json['shift_id']?.toString(),
//       shiftType: json['shift_type']?.toString(),
//       shiftDate: _tryParseDate(json['shift_date']),
//       startTime: _tryParseDate(json['start_time']),
//       latitude: _toDouble(json['latitude']),
//       longitude: _toDouble(json['longitude']),
//       timestamp: _tryParseDate(json['timestamp']),
//       distanceMeters: _toInt(json['distance_meters']),
//     );
//   }
// }

// /// =======================
// /// Extensions (Flutter-friendly)
// /// =======================
// class SimpleLatLng {
//   final double lat;
//   final double lng;
//   const SimpleLatLng(this.lat, this.lng);
// }

// extension NearestCaptainX on NearestCaptain {
//   SimpleLatLng get latLng => SimpleLatLng(latitude, longitude);

//   bool get isOnline => status.toLowerCase() == 'online';

//   String get formattedTimestamp {
//     final t = timestamp;
//     if (t == null) return '';
//     return DateFormat('yyyy-MM-dd HH:mm').format(t);
//   }
// }

// /// =======================
// /// Realtime API Client
// /// =======================
// class RealtimeApiClient {
//   RealtimeApiClient({
//     http.Client? client,
//     this.baseUrl = 'https://realtime.baraddy.com',
//     this.timeout = const Duration(seconds: 15),
//   }) : _client = client ?? http.Client(),
//        _ownsClient = client == null;

//   final http.Client _client;
//   final bool _ownsClient;
//   final String baseUrl;
//   final Duration timeout;

//   bool _disposed = false;

//   Uri _uri(String path, [Map<String, String>? query]) {
//     final uri = Uri.parse('$baseUrl$path');
//     return query == null ? uri : uri.replace(queryParameters: query);
//   }

//   Future<CaptainLocation> getCaptainLocationByInternalId({
//     required String internalId,
//   }) async {
//     final res = await _client
//         .get(_uri('/api/v1/captains/$internalId/location'))
//         .timeout(timeout);

//     final json = _safeJsonMap(res.body);

//     if (res.statusCode != 200) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: json['error']?.toString() ?? 'Get location failed',
//         raw: json,
//       );
//     }

//     final loc = json['location'];
//     if (loc is! Map<String, dynamic>) {
//       throw ApiException(message: 'Invalid location payload', raw: json);
//     }

//     return CaptainLocation.fromJson(loc);
//   }

//   Future<HealthResponse> health() async {
//     final res = await _client
//         .get(_uri('/health'))
//         .timeout(
//           timeout,
//           onTimeout: () => throw ApiException(message: 'Health timeout'),
//         );

//     if (res.statusCode != 200) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: 'Health failed',
//         raw: res.body,
//       );
//     }

//     return HealthResponse.fromJson(_safeJsonMap(res.body));
//   }

//   /// ✅ NEW: Register/Upsert captain by driver_id
//   Future<RegisterCaptainResponse> registerCaptain({
//     required int driverId,
//     required String phone,
//     required String name,
//     required String vehicleType,
//   }) async {
//     final body = <String, dynamic>{
//       'driver_id': driverId,
//       'phone': phone,
//       'name': name,
//       'vehicle_type': vehicleType,
//     };

//     final res = await _client
//         .post(
//           _uri('/api/v1/captains'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode(body),
//         )
//         .timeout(
//           timeout,
//           onTimeout: () =>
//               throw ApiException(message: 'Register captain timeout'),
//         );

//     final json = _safeJsonMap(res.body);

//     if (res.statusCode != 200) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: 'Register captain failed',
//         raw: json.isEmpty ? res.body : json,
//       );
//     }

//     final parsed = RegisterCaptainResponse.fromJson(json);
//     if (parsed.success != true || parsed.internalId == null) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: parsed.error ?? 'Register captain returned invalid response',
//         raw: json,
//       );
//     }

//     return parsed;
//   }

//   Future<UpdateLocationResponse> updateCaptainLocation({
//     required String captainInternalId,
//     required double latitude,
//     required double longitude,
//     double? accuracy,
//     double? heading,
//     double? speed,
//   }) async {
//     final body = <String, dynamic>{
//       'latitude': latitude,
//       'longitude': longitude,
//       if (accuracy != null) 'accuracy': accuracy,
//       if (heading != null) 'heading': heading,
//       if (speed != null) 'speed': speed,
//     };

//     final res = await _client
//         .post(
//           _uri('/api/v1/captains/$captainInternalId/location'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode(body),
//         )
//         .timeout(
//           timeout,
//           onTimeout: () =>
//               throw ApiException(message: 'Update location timeout'),
//         );

//     final json = _safeJsonMap(res.body);

//     if (res.statusCode != 200) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: 'Update location failed',
//         raw: json.isEmpty ? res.body : json,
//       );
//     }

//     return UpdateLocationResponse.fromJson(json);
//   }

//   /// 💓 NEW: Heartbeat - إرسال نبضة حياة كل 60 ثانية
//   Future<void> heartbeat({required String captainInternalId}) async {
//     final res = await _client
//         .post(_uri('/api/v1/captains/$captainInternalId/heartbeat'))
//         .timeout(
//           timeout,
//           onTimeout: () => throw ApiException(message: 'Heartbeat timeout'),
//         );

//     final json = _safeJsonMap(res.body);
//     if (res.statusCode != 200) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: 'Heartbeat failed',
//         raw: json.isEmpty ? res.body : json,
//       );
//     }
//   }

//   /// 🔴 NEW: Update Status - تحديث حالة الكابتن (online/offline)
//   Future<void> updateCaptainStatus({
//     required String captainInternalId,
//     required String status,
//   }) async {
//     final res = await _client
//         .patch(
//           _uri('/api/v1/captains/$captainInternalId/status'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({'status': status}),
//         )
//         .timeout(
//           timeout,
//           onTimeout: () => throw ApiException(message: 'Update status timeout'),
//         );

//     final json = _safeJsonMap(res.body);
//     if (res.statusCode != 200) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: 'Update status failed',
//         raw: json.isEmpty ? res.body : json,
//       );
//     }
//   }

//   Future<NearestResponse> getNearestCaptain({
//     required double lat,
//     required double lng,
//     int radius = 5000,
//   }) async {
//     final res = await _client
//         .get(
//           _uri('/api/v1/captains/nearest', {
//             'lat': lat.toString(),
//             'lng': lng.toString(),
//             'radius': radius.toString(),
//           }),
//         )
//         .timeout(
//           timeout,
//           onTimeout: () => throw ApiException(message: 'Nearest timeout'),
//         );

//     if (res.statusCode != 200) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: 'Nearest failed',
//         raw: res.body,
//       );
//     }

//     return NearestResponse.fromJson(_safeJsonMap(res.body));
//   }

//   void dispose() {
//     if (_disposed) return;
//     _disposed = true;
//     if (_ownsClient) _client.close();
//   }

//   Map<String, dynamic> _safeJsonMap(String body) {
//     try {
//       final v = jsonDecode(body);
//       if (v is Map<String, dynamic>) return v;
//       return <String, dynamic>{'raw': v};
//     } catch (_) {
//       return <String, dynamic>{'raw': body};
//     }
//   }

//   Future<CaptainLocation> getCaptainLocationByDriverId({
//     required int driverId,
//   }) async {
//     final res = await _client
//         .get(_uri('/api/v1/drivers/$driverId/location'))
//         .timeout(timeout);

//     final json = _safeJsonMap(res.body);

//     if (res.statusCode != 200) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message: json['error']?.toString() ?? 'Get location failed',
//         raw: json.isEmpty ? res.body : json,
//       );
//     }

//     final loc = json['location'];
//     if (loc is! Map<String, dynamic>) {
//       throw ApiException(
//         statusCode: res.statusCode,
//         message:
//             json['error']?.toString() ??
//             json['message']?.toString() ??
//             'Invalid location payload',
//         raw: json,
//       );
//     }

//     return CaptainLocation.fromJson(loc);
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// =======================
/// Parsing helpers (safe)
/// =======================
double? _toNullableDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

double _toDouble(dynamic v, {double defaultValue = 0.0}) {
  return _toNullableDouble(v) ?? defaultValue;
}

int? _toNullableInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

int _toInt(dynamic v, {int defaultValue = 0}) {
  return _toNullableInt(v) ?? defaultValue;
}

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

String _toStringSafe(dynamic v, {String defaultValue = ''}) {
  if (v == null) return defaultValue;
  return v.toString();
}

/// =======================
/// Error model
/// =======================
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic raw;

  ApiException({required this.message, this.statusCode, this.raw});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

/// =======================
/// Models
/// =======================
class HealthResponse {
  final String status;
  final DateTime? timestamp;
  final String environment;

  HealthResponse({
    required this.status,
    required this.timestamp,
    required this.environment,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: _toStringSafe(json['status']),
      timestamp: _tryParseDate(json['timestamp']),
      environment: _toStringSafe(json['environment']),
    );
  }
}

class Captain {
  final String id;
  final String phone;
  final String internalId;
  final String name;
  final String vehicleType;
  final String status;
  final String rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? driverId;

  Captain({
    required this.id,
    required this.phone,
    required this.internalId,
    required this.name,
    required this.vehicleType,
    required this.status,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.driverId,
  });

  factory Captain.fromJson(Map<String, dynamic> json) {
    return Captain(
      id: _toStringSafe(json['id']),
      phone: _toStringSafe(json['phone']),
      internalId: _toStringSafe(json['internal_id']),
      name: _toStringSafe(json['name']),
      vehicleType: _toStringSafe(json['vehicle_type']),
      status: _toStringSafe(json['status']),
      rating: _toStringSafe(json['rating']),
      createdAt: _tryParseDate(json['created_at']),
      updatedAt: _tryParseDate(json['updated_at']),
      driverId: _toNullableInt(json['driver_id']),
    );
  }
}

class Shift {
  final String id;
  final String captainId;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String status;
  final String earnings;
  final DateTime? createdAt;
  final String shiftType;
  final DateTime? shiftDate;

  Shift({
    required this.id,
    required this.captainId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    required this.earnings,
    required this.createdAt,
    required this.shiftType,
    required this.shiftDate,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: _toStringSafe(json['id']),
      captainId: _toStringSafe(json['captain_id']),
      startTime: _tryParseDate(json['start_time']),
      endTime: _tryParseDate(json['end_time']),
      durationMinutes: _toNullableInt(json['duration_minutes']),
      status: _toStringSafe(json['status']),
      earnings: _toStringSafe(json['earnings']),
      createdAt: _tryParseDate(json['created_at']),
      shiftType: _toStringSafe(json['shift_type']),
      shiftDate: _tryParseDate(json['shift_date']),
    );
  }
}

class RegisterCaptainResponse {
  final bool success;
  final String? error;
  final String? code;
  final String? internalId;
  final Captain? captain;
  final Shift? shift;

  RegisterCaptainResponse({
    required this.success,
    required this.error,
    required this.code,
    required this.internalId,
    required this.captain,
    required this.shift,
  });

  factory RegisterCaptainResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map<String, dynamic> ? data : null;

    return RegisterCaptainResponse(
      success: json['success'] == true,
      error: json['error']?.toString() ?? json['message']?.toString(),
      code: json['code']?.toString(),
      internalId: dataMap?['internal_id']?.toString(),
      captain: (dataMap?['captain'] is Map<String, dynamic>)
          ? Captain.fromJson(dataMap!['captain'] as Map<String, dynamic>)
          : null,
      shift: (dataMap?['shift'] is Map<String, dynamic>)
          ? Shift.fromJson(dataMap!['shift'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UpdateLocationResponse {
  final bool success;
  final CaptainLocation? location;
  final String? error;

  UpdateLocationResponse({
    required this.success,
    required this.location,
    required this.error,
  });

  factory UpdateLocationResponse.fromJson(Map<String, dynamic> json) {
    return UpdateLocationResponse(
      success: json['success'] == true,
      location: json['location'] == null
          ? null
          : CaptainLocation.fromJson(json['location'] as Map<String, dynamic>),
      error: json['error']?.toString(),
    );
  }
}

class CaptainLocation {
  final String id;
  final String captainId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? heading;
  final double? speed;
  final DateTime? timestamp;
  final String? locationGeom;

  CaptainLocation({
    required this.id,
    required this.captainId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.heading,
    required this.speed,
    required this.timestamp,
    required this.locationGeom,
  });

  factory CaptainLocation.fromJson(Map<String, dynamic> json) {
    return CaptainLocation(
      id: _toStringSafe(json['id']),
      captainId: _toStringSafe(json['captain_id']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      accuracy: _toNullableDouble(json['accuracy']),
      heading: _toNullableDouble(json['heading']),
      speed: _toNullableDouble(json['speed']),
      timestamp: _tryParseDate(json['timestamp']),
      locationGeom: json['location']?.toString(),
    );
  }
}

class NearestResponse {
  final bool success;
  final NearestCaptain? nearest;
  final int count;
  final String? error;

  NearestResponse({
    required this.success,
    required this.nearest,
    required this.count,
    required this.error,
  });

  factory NearestResponse.fromJson(Map<String, dynamic> json) {
    final n = json['nearest'];
    return NearestResponse(
      success: json['success'] == true,
      nearest: (n is Map<String, dynamic>) ? NearestCaptain.fromJson(n) : null,
      count: _toInt(json['count']),
      error: json['error']?.toString(),
    );
  }
}

class NearestCaptain {
  final String internalId;
  final String phone;
  final String name;
  final String vehicleType;
  final String status;

  final String? shiftId;
  final String? shiftType;
  final DateTime? shiftDate;
  final DateTime? startTime;

  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final int distanceMeters;

  NearestCaptain({
    required this.internalId,
    required this.phone,
    required this.name,
    required this.vehicleType,
    required this.status,
    required this.shiftId,
    required this.shiftType,
    required this.shiftDate,
    required this.startTime,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.distanceMeters,
  });

  factory NearestCaptain.fromJson(Map<String, dynamic> json) {
    return NearestCaptain(
      internalId: _toStringSafe(json['internal_id']),
      phone: _toStringSafe(json['phone']),
      name: _toStringSafe(json['name']),
      vehicleType: _toStringSafe(json['vehicle_type']),
      status: _toStringSafe(json['status']),
      shiftId: json['shift_id']?.toString(),
      shiftType: json['shift_type']?.toString(),
      shiftDate: _tryParseDate(json['shift_date']),
      startTime: _tryParseDate(json['start_time']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      timestamp: _tryParseDate(json['timestamp']),
      distanceMeters: _toInt(json['distance_meters']),
    );
  }
}

/// =======================
/// Extensions (Flutter-friendly)
/// =======================
class SimpleLatLng {
  final double lat;
  final double lng;
  const SimpleLatLng(this.lat, this.lng);
}

extension NearestCaptainX on NearestCaptain {
  SimpleLatLng get latLng => SimpleLatLng(latitude, longitude);

  bool get isOnline => status.toLowerCase() == 'online';

  String get formattedTimestamp {
    final t = timestamp;
    if (t == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(t);
  }
}

/// =======================
/// Realtime API Client
/// =======================
class RealtimeApiClient {
  RealtimeApiClient({
    http.Client? client,
    this.baseUrl = 'https://realtime.baraddy.com',
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final String baseUrl;
  final Duration timeout;

  bool _disposed = false;

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$baseUrl$path');
    return query == null ? uri : uri.replace(queryParameters: query);
  }

  Future<HealthResponse> health() async {
    final res = await _client
        .get(_uri('/health'))
        .timeout(
          timeout,
          onTimeout: () => throw ApiException(message: 'Health timeout'),
        );

    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Health failed',
        raw: res.body,
      );
    }

    return HealthResponse.fromJson(_safeJsonMap(res.body));
  }

  /// ✅ NEW: Register/Upsert captain by driver_id
  Future<RegisterCaptainResponse> registerCaptain({
    required int driverId,
    required String phone,
    required String name,
    required String vehicleType,
  }) async {
    final body = <String, dynamic>{
      'driver_id': driverId,
      'phone': phone,
      'name': name,
      'vehicle_type': vehicleType,
    };

    final res = await _client
        .post(
          _uri('/api/v1/captains'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(
          timeout,
          onTimeout: () =>
              throw ApiException(message: 'Register captain timeout'),
        );

    final json = _safeJsonMap(res.body);

    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Register captain failed',
        raw: json.isEmpty ? res.body : json,
      );
    }

    final parsed = RegisterCaptainResponse.fromJson(json);
    if (parsed.success != true || parsed.internalId == null) {
      throw ApiException(
        statusCode: res.statusCode,
        message: parsed.error ?? 'Register captain returned invalid response',
        raw: json,
      );
    }

    return parsed;
  }

  Future<UpdateLocationResponse> updateCaptainLocation({
    required String captainInternalId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? heading,
    double? speed,
  }) async {
    final body = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
    };

    final res = await _client
        .post(
          _uri('/api/v1/captains/$captainInternalId/location'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(
          timeout,
          onTimeout: () =>
              throw ApiException(message: 'Update location timeout'),
        );

    final json = _safeJsonMap(res.body);

    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Update location failed',
        raw: json.isEmpty ? res.body : json,
      );
    }

    return UpdateLocationResponse.fromJson(json);
  }

  /// 💓 NEW: Heartbeat - إرسال نبضة حياة كل 60 ثانية
  Future<void> heartbeat({required String captainInternalId}) async {
    final res = await _client
        .post(_uri('/api/v1/captains/$captainInternalId/heartbeat'))
        .timeout(
          timeout,
          onTimeout: () => throw ApiException(message: 'Heartbeat timeout'),
        );

    final json = _safeJsonMap(res.body);
    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Heartbeat failed',
        raw: json.isEmpty ? res.body : json,
      );
    }
  }

  /// 🔴 NEW: Update Status - تحديث حالة الكابتن (online/offline)
  Future<void> updateCaptainStatus({
    required String captainInternalId,
    required String status,
  }) async {
    final res = await _client
        .patch(
          _uri('/api/v1/captains/$captainInternalId/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'status': status}),
        )
        .timeout(
          timeout,
          onTimeout: () => throw ApiException(message: 'Update status timeout'),
        );

    final json = _safeJsonMap(res.body);
    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Update status failed',
        raw: json.isEmpty ? res.body : json,
      );
    }
  }

  Future<NearestResponse> getNearestCaptain({
    required double lat,
    required double lng,
    int radius = 5000,
  }) async {
    final res = await _client
        .get(
          _uri('/api/v1/captains/nearest', {
            'lat': lat.toString(),
            'lng': lng.toString(),
            'radius': radius.toString(),
          }),
        )
        .timeout(
          timeout,
          onTimeout: () => throw ApiException(message: 'Nearest timeout'),
        );

    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Nearest failed',
        raw: res.body,
      );
    }

    return NearestResponse.fromJson(_safeJsonMap(res.body));
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_ownsClient) _client.close();
  }

  Map<String, dynamic> _safeJsonMap(String body) {
    try {
      final v = jsonDecode(body);
      if (v is Map<String, dynamic>) return v;
      return <String, dynamic>{'raw': v};
    } catch (_) {
      return <String, dynamic>{'raw': body};
    }
  }

  Future<CaptainLocation> getCaptainLocationByDriverId({
    required int driverId,
  }) async {
    final res = await _client
        .get(_uri('/api/v1/drivers/$driverId/location'))
        .timeout(timeout);

    final json = _safeJsonMap(res.body);
    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Get location failed',
      );
    }
    return CaptainLocation.fromJson(json['location']);
  }
}
