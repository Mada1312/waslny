import 'dart:convert';
import 'package:http/http.dart' as http;

class PricingEngine {
  // تسعير السائق الرجل
  static const double malePricePerKm = 9.5;
  static const double maleMinTripPrice = 30.0;

  // تسعير السائقة السيدة
  static const double femalePricePerKm = 10.5;
  static const double femaleMinTripPrice = 35.0;

  /// ✅ الدالة الجديدة: تحسب السعر من الإحداثيات مباشرة
  static Future<double?> calculateTripPriceFromCoordinates({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    required bool isFemaleDriver,
  }) async {
    // جيب المسافة من OSRM
    final distanceKm = await _getRouteDistanceKm(
      fromLat,
      fromLng,
      toLat,
      toLng,
    );
    if (distanceKm == null) return null; // فشل الشبكة

    // احسب السعر
    return calculateTripPrice(
      distanceKm: distanceKm,
      isFemaleDriver: isFemaleDriver,
    );
  }

  /// حساب السعر القديم (استخدمه لو عندك المسافة جاهزة)
  static double calculateTripPrice({
    required double distanceKm,
    required bool isFemaleDriver,
  }) {
    double pricePerKm = isFemaleDriver ? femalePricePerKm : malePricePerKm;
    double minPrice = isFemaleDriver ? femaleMinTripPrice : maleMinTripPrice;

    double price = distanceKm * pricePerKm;
    if (price < minPrice) price = minPrice;

    return price.round().toDouble();
  }

  /// جلب المسافة من OSRM (داخلي)
  static Future<double?> _getRouteDistanceKm(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$fromLng,$fromLat;$toLng,$toLat?overview=false',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'];
        if (routes != null && routes.isNotEmpty) {
          final distanceMeters = (routes[0]['distance'] as num).toDouble();
          return distanceMeters / 1000; // كم
        }
      }
    } catch (e) {
      // لا تعمل print، استخدم logger لو عندك
    }
    return null;
  }
}
