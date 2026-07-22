import 'package:landmark_navigation_app/models/event.dart';
import 'package:landmark_navigation_app/services/api_client.dart';

class EventService {
  final ApiClient _client = ApiClient();

  Future<Event> createEvent({
    int? sessionId,
    int? stepId,
    String? eventType,
    DateTime? timestamp,
    int? reactionTimeMs,
    double? userLat,
    double? userLng,
    Map<String, dynamic>? metadata,
  }) async {
    final body = await _client.postJson('/events', {
      if (sessionId != null) 'session_id': sessionId,
      if (stepId != null) 'step_id': stepId,
      if (eventType != null) 'event_type': eventType,
      if (timestamp != null) 'timestamp': timestamp.toUtc().toIso8601String(),
      if (reactionTimeMs != null) 'reaction_time_ms': reactionTimeMs,
      if (userLat != null) 'user_lat': userLat,
      if (userLng != null) 'user_lng': userLng,
      if (metadata != null) 'metadata': metadata,
    });
    return Event.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Event>> getEvents() async {
    final body = await _client.getJson('/events');
    return (body['data'] as List<dynamic>)
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Event> getEvent(int id) async {
    final body = await _client.getJson('/events/$id');
    return Event.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Event> updateEvent(
    int id, {
    int? sessionId,
    int? stepId,
    String? eventType,
    DateTime? timestamp,
    int? reactionTimeMs,
    double? userLat,
    double? userLng,
    Map<String, dynamic>? metadata,
  }) async {
    final body = await _client.patchJson('/events/$id', {
      if (sessionId != null) 'session_id': sessionId,
      if (stepId != null) 'step_id': stepId,
      if (eventType != null) 'event_type': eventType,
      if (timestamp != null) 'timestamp': timestamp.toUtc().toIso8601String(),
      if (reactionTimeMs != null) 'reaction_time_ms': reactionTimeMs,
      if (userLat != null) 'user_lat': userLat,
      if (userLng != null) 'user_lng': userLng,
      if (metadata != null) 'metadata': metadata,
    });
    return Event.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteEvent(int id) async {
    await _client.deleteJson('/events/$id');
  }
}
