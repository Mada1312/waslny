// import 'dart:developer';
// import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';

// class PricingEngine {
//   static const double maleRatePerKm = 9.5;
//   static const double femaleRatePerKm = 10.5;
//   static const double minimumFare = 30.0;

//   /// 🔥 حساب السعر من الرحلة نفسها
//   static int calculateFareFromTrip({
//     required DriverTripModel trip,
//     required bool isFemaleDriver,
//   }) {
//     final double distanceKm = _parseDistance(trip.distance);

//     log('📏 Trip Distance: $distanceKm km');

//     final double rate = isFemaleDriver ? femaleRatePerKm : maleRatePerKm;
//     double price = distanceKm * rate;

//     if (price < minimumFare) {
//       price = minimumFare;
//     }

//     final int finalPrice = price.round();
//     log('💰 Final Price: $finalPrice');

//     return finalPrice;
//   }

//   /// 🔎 تحويل المسافة القادمة من السيرفر
//   static double _parseDistance(String? distance) {
//     if (distance == null || distance.isEmpty) return 0.0;

//     final parsed = double.tryParse(distance);
//     if (parsed == null) return 0.0;

//     return parsed;
//   }
// }
import 'dart:developer';

import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';

class PricingEngine {
  static const double maleRatePerKm = 9.5;
  static const double femaleRatePerKm = 10.5;
  static const double minimumFare = 30.0;

  /// 🔥 حساب السعر من الرحلة نفسها (سواء DriverTripModel أو TripAndServiceModel)
  static int calculateFare({
    required dynamic
    trip, // يمكن أن يكون DriverTripModel أو TripAndServiceModel
    required bool isFemaleDriver,
  }) {
    final double distanceKm = _parseDistance(_extractDistance(trip));

    log('📏 Trip Distance: $distanceKm km');

    final double rate = isFemaleDriver ? femaleRatePerKm : maleRatePerKm;
    double price = distanceKm * rate;

    if (price < minimumFare) {
      price = minimumFare;
    }

    final int finalPrice = price.round();
    log('💰 Final Price: $finalPrice');

    return finalPrice;
  }

  /// 🔎 استخراج المسافة حسب نوع الموديل
  static String? _extractDistance(dynamic trip) {
    if (trip is DriverTripModel) {
      return trip.distance;
    } else if (trip is TripAndServiceModel) {
      return trip.distance;
    }
    return '0';
  }

  /// 🔎 تحويل المسافة القادمة من السيرفر
  static double _parseDistance(String? distance) {
    if (distance == null || distance.isEmpty) return 0.0;

    final parsed = double.tryParse(distance);
    if (parsed == null) return 0.0;

    return parsed;
  }
}
