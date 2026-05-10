import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:landmark_navigation_app/utils/polyline_utils.dart';

typedef RouteResult = ({List<LatLng> points, LatLngBounds bounds});

class DirectionsService {
  Future<RouteResult?> fetchRoute(LatLng origin, LatLng destination) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final uri = Uri.parse(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'routes.polyline.encodedPolyline,routes.viewport',
      },
      body: jsonEncode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': origin.latitude,
              'longitude': origin.longitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destination.latitude,
              'longitude': destination.longitude,
            },
          },
        },
        'travelMode': 'DRIVE',
      }),
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) return null;

    final route = routes[0] as Map<String, dynamic>;
    final points = PolylineUtils.decode(
      route['polyline']['encodedPolyline'] as String,
    );

    final viewport = route['viewport'] as Map<String, dynamic>;
    final high = viewport['high'] as Map<String, dynamic>;
    final low = viewport['low'] as Map<String, dynamic>;
    final bounds = LatLngBounds(
      northeast: LatLng(
        (high['latitude'] as num).toDouble(),
        (high['longitude'] as num).toDouble(),
      ),
      southwest: LatLng(
        (low['latitude'] as num).toDouble(),
        (low['longitude'] as num).toDouble(),
      ),
    );

    return (points: points, bounds: bounds);
  }
}
