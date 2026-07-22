import 'package:landmark_navigation_app/models/user.dart';
import 'package:landmark_navigation_app/services/api_client.dart';

class UserService {
  final ApiClient _client = ApiClient();

  Future<User> createUser({
    required String deviceId,
    String? preferredMode,
    bool? consentResearch,
  }) async {
    final body = await _client.postJson('/users', {
      'device_id': deviceId,
      if (preferredMode != null) 'preferred_mode': preferredMode,
      if (consentResearch != null) 'consent_research': consentResearch,
    });
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<User>> getUsers() async {
    final body = await _client.getJson('/users');
    return (body['data'] as List<dynamic>)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<User> getUser(int id) async {
    final body = await _client.getJson('/users/$id');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> updateUser(
    int id, {
    String? preferredMode,
    bool? consentResearch,
  }) async {
    final body = await _client.patchJson('/users/$id', {
      if (preferredMode != null) 'preferred_mode': preferredMode,
      if (consentResearch != null) 'consent_research': consentResearch,
    });
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> upsertUser({required String deviceId}) async {
    final body = await _client.postJson('/users/upsert', {
      'device_id': deviceId,
    });
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    await _client.deleteJson('/users/$id');
  }
}
