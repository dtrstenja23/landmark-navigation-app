import 'package:landmark_navigation_app/models/route.dart';
import 'package:landmark_navigation_app/services/api_client.dart';

class RouteService {
  final ApiClient _client = ApiClient();

  Future<RouteModel> createRoute({
    int? userId,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? polyline,
    int? totalDistanceM,
  }) async {
    final body = await _client.postJson('/routes', {
      if (userId != null) 'user_id': userId,
      'origin_lat': originLat,
      'origin_lng': originLng,
      'dest_lat': destLat,
      'dest_lng': destLng,
      if (polyline != null) 'polyline': polyline,
      if (totalDistanceM != null) 'total_distance_m': totalDistanceM,
    });
    return RouteModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<RouteModel>> getRoutes() async {
    final body = await _client.getJson('/routes');
    return (body['data'] as List<dynamic>)
        .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RouteModel> getRoute(int id) async {
    final body = await _client.getJson('/routes/$id');
    return RouteModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<RouteModel> updateRoute(
    int id, {
    int? userId,
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
    String? polyline,
    int? totalDistanceM,
  }) async {
    final body = await _client.patchJson('/routes/$id', {
      if (userId != null) 'user_id': userId,
      if (originLat != null) 'origin_lat': originLat,
      if (originLng != null) 'origin_lng': originLng,
      if (destLat != null) 'dest_lat': destLat,
      if (destLng != null) 'dest_lng': destLng,
      if (polyline != null) 'polyline': polyline,
      if (totalDistanceM != null) 'total_distance_m': totalDistanceM,
    });
    return RouteModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteRoute(int id) async {
    await _client.deleteJson('/routes/$id');
  }
}
