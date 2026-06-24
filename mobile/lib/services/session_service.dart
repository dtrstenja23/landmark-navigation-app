import 'package:landmark_navigation_app/models/session.dart';
import 'package:landmark_navigation_app/services/api_client.dart';

class SessionService {
  final ApiClient _client = ApiClient();

  Future<Session> createSession({
    int? userId,
    int? routeId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? mode,
  }) async {
    final body = await _client.postJson('/sessions', {
      if (userId != null) 'user_id': userId,
      if (routeId != null) 'route_id': routeId,
      if (startedAt != null) 'started_at': startedAt.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt.toIso8601String(),
      if (mode != null) 'mode': mode,
    });
    return Session.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Session>> getSessions() async {
    final body = await _client.getJson('/sessions');
    return (body['data'] as List<dynamic>)
        .map((e) => Session.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Session> getSession(int id) async {
    final body = await _client.getJson('/sessions/$id');
    return Session.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Session> updateSession(
    int id, {
    int? userId,
    int? routeId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? mode,
  }) async {
    final body = await _client.patchJson('/sessions/$id', {
      if (userId != null) 'user_id': userId,
      if (routeId != null) 'route_id': routeId,
      if (startedAt != null) 'started_at': startedAt.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt.toIso8601String(),
      if (mode != null) 'mode': mode,
    });
    return Session.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteSession(int id) async {
    await _client.deleteJson('/sessions/$id');
  }
}
