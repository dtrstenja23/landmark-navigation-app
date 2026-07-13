import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/route.dart';
import 'package:landmark_navigation_app/services/api_client.dart';

class RouteGenerationService {
  final ApiClient _client = ApiClient();

  Future<RouteModel> generateRoute({
    required String deviceId,
    required LatLng origin,
    required LatLng destination,
    required String travelMode,
    required String mode,
  }) async {
    final body = await _client.postJson('/routes/generate', {
      'device_id': deviceId,
      'origin': {'lat': origin.latitude, 'lng': origin.longitude},
      'destination': {
        'lat': destination.latitude,
        'lng': destination.longitude,
      },
      'travel_mode': travelMode,
      'mode': mode,
    });

    return RouteModel.fromJson(body['data'] as Map<String, dynamic>);
  }
}
