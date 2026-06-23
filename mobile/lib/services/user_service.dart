import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:landmark_navigation_app/models/user.dart';
import 'package:landmark_navigation_app/services/api_client.dart';

class UserService {
  final ApiClient _client = ApiClient();

  Future<User> createUser({
    required String deviceId,
    String? preferredMode,
    bool? consentResearch,
  }) async {
    final response = await http.post(
      _client.uri('/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        if (preferredMode != null) 'preferred_mode': preferredMode,
        if (consentResearch != null) 'consent_research': consentResearch,
      }),
    );
    final body = _client.decode(response);
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<User>> getUsers() async {
    final response = await http.get(_client.uri('/users'));
    final body = _client.decode(response);
    return (body['data'] as List<dynamic>)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<User> getUser(int id) async {
    final response = await http.get(_client.uri('/users/$id'));
    final body = _client.decode(response);
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> updateUser(
    int id, {
    String? preferredMode,
    bool? consentResearch,
  }) async {
    final response = await http.patch(
      _client.uri('/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (preferredMode != null) 'preferred_mode': preferredMode,
        if (consentResearch != null) 'consent_research': consentResearch,
      }),
    );
    final body = _client.decode(response);
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(_client.uri('/users/$id'));
    _client.checkStatus(response);
  }
}
