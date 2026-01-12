import 'package:waslny/core/exports.dart';
import 'package:waslny/core/real-time/realtime_api.dart';

/// ===========================
/// Model for nearest captain
/// ===========================
class NearestCaptainModel {
  final String internalId;
  final String name;
  final String phone;
  final String vehicleType;
  final String status;

  final double latitude;
  final double longitude;
  final int distanceMeters;
  final DateTime? lastUpdated;

  final String? shiftId;
  final String? shiftType;
  final DateTime? shiftDate;
  final DateTime? shiftStartTime;

  NearestCaptainModel({
    required this.internalId,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.lastUpdated,
    this.shiftId,
    this.shiftType,
    this.shiftDate,
    this.shiftStartTime,
  });

  /// Convert from Realtime API's NearestCaptain
  factory NearestCaptainModel.fromNearestCaptain(NearestCaptain cap) {
    return NearestCaptainModel(
      internalId: cap.internalId,
      name: cap.name,
      phone: cap.phone,
      vehicleType: cap.vehicleType,
      status: cap.status,
      latitude: cap.latitude,
      longitude: cap.longitude,
      distanceMeters: cap.distanceMeters,
      lastUpdated: cap.timestamp,
      shiftId: cap.shiftId,
      shiftType: cap.shiftType,
      shiftDate: cap.shiftDate,
      shiftStartTime: cap.startTime,
    );
  }

  /// Convenience method for Flutter maps
  SimpleLatLng get latLng => SimpleLatLng(latitude, longitude);

  /// Check if the captain is online
  bool get isOnline => status.toLowerCase() == 'online';

  /// Formatted timestamp for UI
  String get formattedLastUpdated {
    if (lastUpdated == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(lastUpdated!);
  }

  /// Optional: format distance in km
  String get formattedDistance {
    if (distanceMeters >= 1000) {
      final km = (distanceMeters / 1000);
      return '${km.toStringAsFixed(1)} km';
    }
    return '$distanceMeters m';
  }
}
