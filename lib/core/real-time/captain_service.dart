import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ===============================
/// Models
/// ===============================

class LiveLocation {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final double? accuracy;
  final double? speed; // m/s
  final double? heading;

  LiveLocation({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.accuracy,
    this.speed,
    this.heading,
  });

  factory LiveLocation.fromApi(Map<String, dynamic> json) {
    return LiveLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: (json['speed'] is num) ? (json['speed'] as num).toDouble() : null,
      heading: (json['heading'] is num)
          ? (json['heading'] as num).toDouble()
          : null,
      accuracy: (json['accuracy'] is num)
          ? (json['accuracy'] as num).toDouble()
          : null,
      updatedAt: _parseApiUpdatedAt(json['updated_at']),
    );
  }

  static DateTime _parseApiUpdatedAt(dynamic v) {
    // backend يرجع updated_at كـ millis (زي اللي ظهر عندك: 1768832348979)
    if (v == null) return DateTime.now();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v, isUtc: false);
    if (v is num)
      return DateTime.fromMillisecondsSinceEpoch(v.toInt(), isUtc: false);
    if (v is String) {
      final asInt = int.tryParse(v);
      if (asInt != null)
        return DateTime.fromMillisecondsSinceEpoch(asInt, isUtc: false);
      final dt = DateTime.tryParse(v);
      if (dt != null) return dt;
    }
    return DateTime.now();
  }

  @override
  String toString() =>
      'LiveLocation(lat:$latitude,lng:$longitude,acc:$accuracy,speed:$speed,heading:$heading,updatedAt:$updatedAt)';
}

class HistoryPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? heading;
  final double? accuracy;

  HistoryPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.heading,
    this.accuracy,
  });

  factory HistoryPoint.fromApi(Map<String, dynamic> json) {
    // history values ممكن تبقى String زي "30.05000000"
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    DateTime _toDate(dynamic v) {
      if (v is String) {
        final dt = DateTime.tryParse(v);
        if (dt != null) return dt;
      }
      return DateTime.now();
    }

    return HistoryPoint(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      speed: json['speed'] == null ? null : _toDouble(json['speed']),
      heading: json['heading'] == null ? null : _toDouble(json['heading']),
      accuracy: json['accuracy'] == null ? null : _toDouble(json['accuracy']),
      timestamp: _toDate(json['timestamp']),
    );
  }
}

enum CaptainConnectionState { online, offline, idle }

class CaptainInfo {
  final String id; // uuid
  final int driverId; // int
  final String internalId; // uuid
  final String? name;
  final String? phone;
  final String? status;
  final bool? isOnline;

  CaptainInfo({
    required this.id,
    required this.driverId,
    required this.internalId,
    this.name,
    this.phone,
    this.status,
    this.isOnline,
  });

  factory CaptainInfo.fromApi(Map<String, dynamic> json) {
    return CaptainInfo(
      id: (json['id'] ?? '').toString(),
      driverId: (json['driver_id'] is num)
          ? (json['driver_id'] as num).toInt()
          : int.tryParse('${json['driver_id']}') ?? 0,
      internalId: (json['internal_id'] ?? '').toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status']?.toString(),
      isOnline: json['is_online'] is bool ? json['is_online'] as bool : null,
    );
  }
}

class TrackingData {
  final CaptainInfo captain;
  final LiveLocation? liveLocation;
  final List<HistoryPoint> history;
  final CaptainConnectionState connectionState;
  final DateTime fetchedAt;

  TrackingData({
    required this.captain,
    required this.liveLocation,
    required this.history,
    required this.connectionState,
    required this.fetchedAt,
  });

  bool get isMoving => (liveLocation?.speed ?? 0) > 0.5;

  @override
  String toString() =>
      'TrackingData(captain:${captain.driverId}, live:$liveLocation, history:${history.length}, state:$connectionState)';
}

/// ===============================
/// Service (Real API)
/// ===============================

class CaptainTrackingService {
  final String baseUrl; // e.g. https://realtime.baraddy.com
  final Duration timeout;
  final http.Client _client;

  CaptainTrackingService({
    this.baseUrl = 'https://realtime.baraddy.com',
    this.timeout = const Duration(seconds: 12),
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// GET /api/v1/captains/{driverId}/tracking?historyLimit=...
  Future<TrackingData> getTrackingByDriverId(
    int driverId, {
    int historyLimit = 100,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/captains/$driverId/tracking')
        .replace(
          queryParameters: {
            'historyLimit': historyLimit.toString(),
            // لو حبيت تحدّث heartbeat من هنا خلّيها true
            // 'updateHeartbeat': 'true',
          },
        );

    try {
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('HTTP ${res.statusCode}: ${res.body}');
      }

      final Map<String, dynamic> body = jsonDecode(res.body);
      if (body['success'] != true) {
        throw Exception(body['error'] ?? 'Unknown tracking error');
      }

      final captain = CaptainInfo.fromApi(
        body['captain'] as Map<String, dynamic>,
      );
      final liveJson = body['liveLocation'];
      final live = (liveJson is Map<String, dynamic>)
          ? LiveLocation.fromApi(liveJson)
          : null;

      final histList = (body['history'] is List)
          ? (body['history'] as List)
          : const [];
      final history = histList
          .whereType<Map<String, dynamic>>()
          .map((e) => HistoryPoint.fromApi(e))
          .toList();

      final state = _connectionFromCaptain(captain);

      final data = TrackingData(
        captain: captain,
        liveLocation: live,
        history: history,
        connectionState: state,
        fetchedAt: DateTime.now(),
      );

      if (kDebugMode) {
        // ignore: avoid_print
        print('[CaptainTrackingService] $data');
      }
      return data;
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timeout');
    }
  }

  CaptainConnectionState _connectionFromCaptain(CaptainInfo c) {
    final s = (c.status ?? '').toLowerCase();
    final on = c.isOnline == true;
    if (on || s == 'online') return CaptainConnectionState.online;
    if (s == 'offline') return CaptainConnectionState.offline;
    return CaptainConnectionState.idle;
  }

  /// Stream polling كل 3 ثواني
  Stream<TrackingData> trackingStreamByDriverId(
    int driverId, {
    Duration interval = const Duration(seconds: 3),
    int historyLimit = 100,
  }) async* {
    while (true) {
      yield await getTrackingByDriverId(driverId, historyLimit: historyLimit);
      await Future.delayed(interval);
    }
  }

  void dispose() {
    _client.close();
  }
}
