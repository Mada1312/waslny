import 'dart:math' as math;
import 'package:latlong2/latlong.dart' as ll;

// ✅ حساب bearing من نقطتين (بالدرجات 0..360)
double bearingDegrees(ll.LatLng a, ll.LatLng b) {
  final lat1 = _degToRad(a.latitude);
  final lat2 = _degToRad(b.latitude);
  final dLon = _degToRad(b.longitude - a.longitude);

  final y = math.sin(dLon) * math.cos(lat2);
  final x =
      math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

  final brngRad = math.atan2(y, x);
  final brngDeg = (_radToDeg(brngRad) + 360.0) % 360.0;
  return brngDeg;
}

// ✅ Smoothing للزاوية (يتجنب مشكلة 359 -> 0)
double smoothAngleDeg({
  required double previousDeg,
  required double targetDeg,
  required double alpha, // 0..1 (مثلاً 0.15)
}) {
  // فرق الزاوية بأقصر طريق: -180..180
  final delta = ((targetDeg - previousDeg + 540.0) % 360.0) - 180.0;
  final next = (previousDeg + alpha * delta) % 360.0;
  return (next + 360.0) % 360.0;
}

// ✅ حساب Bearing من الـ Route باستخدام sCurrent + lookAheadMeters
double bearingFromRouteS({
  required double sCurrent,
  required double routeLengthMeters,
  required ll.LatLng Function(double s) latLngOnRouteFromS,
  double lookAheadMeters = 12.0,
}) {
  final sA = sCurrent.clamp(0.0, routeLengthMeters);
  final sB = (sCurrent + lookAheadMeters).clamp(0.0, routeLengthMeters);

  final posA = latLngOnRouteFromS(sA);
  final posB = latLngOnRouteFromS(sB);

  // لو قربنا من نهاية المسار وبقى sA == sB، نحاول lookBehind
  if ((sB - sA).abs() < 0.5) {
    final sBehind = (sCurrent - lookAheadMeters).clamp(0.0, routeLengthMeters);
    final posBehind = latLngOnRouteFromS(sBehind);
    return bearingDegrees(posBehind, posA);
  }

  return bearingDegrees(posA, posB);
}

// ✅ حساب المسافة على المسار من البداية
double distanceAlongRoute(List<ll.LatLng> route, ll.LatLng point) {
  if (route.isEmpty) return 0.0;

  double totalDistance = 0.0;
  const distance = ll.Distance();

  for (int i = 0; i < route.length - 1; i++) {
    final segmentDist = distance.as(
      ll.LengthUnit.Meter,
      route[i],
      route[i + 1],
    );
    final pointDist = distance.as(ll.LengthUnit.Meter, point, route[i]);

    if (pointDist < segmentDist * 0.5) {
      // النقطة على الـ segment ده
      return totalDistance + pointDist;
    }

    totalDistance += segmentDist;
  }

  return totalDistance;
}

// ✅ RouteBearingController للـ smoothing
class RouteBearingController {
  double _smoothedBearing = 0.0;
  bool _hasInit = false;

  double update({
    required double sCurrent,
    required double routeLengthMeters,
    required ll.LatLng Function(double s) latLngOnRouteFromS,
    double lookAheadMeters = 12.0,
    double alpha = 0.15,
  }) {
    final target = bearingFromRouteS(
      sCurrent: sCurrent,
      routeLengthMeters: routeLengthMeters,
      latLngOnRouteFromS: latLngOnRouteFromS,
      lookAheadMeters: lookAheadMeters,
    );

    if (!_hasInit) {
      _smoothedBearing = target;
      _hasInit = true;
      return _smoothedBearing;
    }

    _smoothedBearing = smoothAngleDeg(
      previousDeg: _smoothedBearing,
      targetDeg: target,
      alpha: alpha,
    );
    return _smoothedBearing;
  }
}

// ✅ Kalman Filter
class KalmanFilterLatLng {
  final double qMetresPerSecond;
  int? _t;
  double _lat = 0;
  double _lng = 0;
  double _variance = -1;

  KalmanFilterLatLng(this.qMetresPerSecond);

  ll.LatLng filter({
    required double lat,
    required double lng,
    required double accuracy,
    required int timestampMs,
  }) {
    final acc = (accuracy.isFinite && accuracy > 0) ? accuracy : 25.0;

    if (_variance < 0) {
      _t = timestampMs;
      _lat = lat;
      _lng = lng;
      _variance = acc * acc;
      return ll.LatLng(_lat, _lng);
    }

    final dt = timestampMs - (_t ?? timestampMs);
    if (dt > 0) {
      _variance += (dt * qMetresPerSecond * qMetresPerSecond) / 1000.0;
      _t = timestampMs;
    }

    final k = _variance / (_variance + acc * acc);
    _lat += k * (lat - _lat);
    _lng += k * (lng - _lng);
    _variance = (1 - k) * _variance;

    return ll.LatLng(_lat, _lng);
  }
}

// ✅ Route Snapper
class RouteSnapper {
  static ll.LatLng snapToRoute(
    ll.LatLng current,
    List<ll.LatLng> route, {
    double maxSnapMeters = 40,
  }) {
    if (route.length < 2) return current;

    double best = double.infinity;
    ll.LatLng bestPoint = current;

    for (int i = 0; i < route.length - 1; i++) {
      final p = _project(route[i], route[i + 1], current);
      final d = const ll.Distance().as(ll.LengthUnit.Meter, current, p);
      if (d < best) {
        best = d;
        bestPoint = p;
      }
    }

    return best <= maxSnapMeters ? bestPoint : current;
  }

  static ll.LatLng _project(ll.LatLng a, ll.LatLng b, ll.LatLng p) {
    final ax = a.latitude, ay = a.longitude;
    final bx = b.latitude, by = b.longitude;
    final px = p.latitude, py = p.longitude;

    final dx = bx - ax;
    final dy = by - ay;
    final len2 = dx * dx + dy * dy;
    if (len2 == 0) return a;

    var t = ((px - ax) * dx + (py - ay) * dy) / len2;
    t = math.max(0, math.min(1, t));

    return ll.LatLng(ax + t * dx, ay + t * dy);
  }
}

// ✅ Helpers
double _degToRad(double deg) => deg * math.pi / 180.0;
double _radToDeg(double rad) => rad * 180.0 / math.pi;

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}
