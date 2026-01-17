// import 'package:waslny/core/api/base_api_consumer.dart';
// import 'package:waslny/core/api/end_points.dart';

// class NavigationRepo {
//   final BaseApiConsumer api;

//   NavigationRepo(this.api);

//   /// احصل على المسار من نقطة البداية للنهاية
//   Future<Map<String, dynamic>> getRoute({
//     required double fromLat,
//     required double fromLng,
//     required double toLat,
//     required double toLng,
//   }) async {
//     try {
//       final res = await api.post(
//         EndPoints.getRouteUrl,
//         body: {
//           "start": {"lat": fromLat, "lng": fromLng},
//           "end": {"lat": toLat, "lng": toLng},
//           "overview": "full",
//           "geometries": "polyline",
//         },
//       );

//       return (res as Map).cast<String, dynamic>();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

import 'package:waslny/core/api/base_api_consumer.dart';
import 'package:waslny/core/api/end_points.dart';

class NavigationRepo {
  final BaseApiConsumer api;
  NavigationRepo(this.api);

  Future<Map<String, dynamic>> getRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final res = await api.post(
      EndPoints.getRouteUrl, // https://api.baraddy.com/api/route
      body: {
        "start": {
          "lat": fromLat,
          "lng": fromLng, // ✅ المطلوب
        },
        "end": {
          "lat": toLat,
          "lng": toLng, // ✅ المطلوب
        },

        // optional (لو السيرفر يدعمهم)
        "overview": "full",
        "geometries": "polyline",
      },
    );

    return (res as Map).cast<String, dynamic>();
  }
}
