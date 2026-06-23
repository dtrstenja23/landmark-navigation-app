import 'package:landmark_navigation_app/models/landmark.dart';
import 'package:landmark_navigation_app/services/api_client.dart';

class LandmarkService {
  final ApiClient _client = ApiClient();

  Future<Landmark> createLandmark({
    required String name,
    required double lat,
    required double lng,
    String? type,
    String? googlePlaceId,
    bool? verified,
    String? source,
  }) async {
    final body = await _client.postJson('/landmarks', {
      'name': name,
      'lat': lat,
      'lng': lng,
      if (type != null) 'type': type,
      if (googlePlaceId != null) 'google_place_id': googlePlaceId,
      if (verified != null) 'verified': verified,
      if (source != null) 'source': source,
    });
    return Landmark.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Landmark>> getLandmarks() async {
    final body = await _client.getJson('/landmarks');
    return (body['data'] as List<dynamic>)
        .map((e) => Landmark.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Landmark> getLandmark(int id) async {
    final body = await _client.getJson('/landmarks/$id');
    return Landmark.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Landmark> updateLandmark(
    int id, {
    String? name,
    double? lat,
    double? lng,
    String? type,
    String? googlePlaceId,
    bool? verified,
    String? source,
  }) async {
    final body = await _client.patchJson('/landmarks/$id', {
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (type != null) 'type': type,
      if (googlePlaceId != null) 'google_place_id': googlePlaceId,
      if (verified != null) 'verified': verified,
      if (source != null) 'source': source,
    });
    return Landmark.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteLandmark(int id) async {
    await _client.deleteJson('/landmarks/$id');
  }
}
