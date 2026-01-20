import 'dart:convert';
import 'package:http/http.dart' as http;

Future<double?> getRouteDistance(
  double fromLat,
  double fromLng,
  double toLat,
  double toLng,
) async {
  try {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/$fromLng,$fromLat;$toLng,$toLat?overview=false',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final double distanceMeters = (data['routes'][0]['distance'] as num)
            .toDouble();
        return distanceMeters / 1000; // بالكيلومتر
      }
    }
  } catch (e) {
    print("Error fetching route distance: $e");
  }
  return null;
}
