import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:landmark_navigation_app/models/user.dart';

class UserService {
  Uri _uri(String path) => Uri.parse('${dotenv.env['API_BASE_URL']}$path');

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(body['error'] ?? 'Request failed (${response.statusCode})');
    }
    return body;
  }

  Future<User> createUser({
    required String deviceId,
    String? preferredMode,
    bool? consentResearch,
  }) async {
    final response = await http.post(
      _uri('/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        if (preferredMode != null) 'preferred_mode': preferredMode,
        if (consentResearch != null) 'consent_research': consentResearch,
      }),
    );
    final body = _decode(response);
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<User>> getUsers() async {
    final response = await http.get(_uri('/users'));
    final body = _decode(response);
    return (body['data'] as List<dynamic>)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<User> getUser(int id) async {
    final response = await http.get(_uri('/users/$id'));
    final body = _decode(response);
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> updateUser(
    int id, {
    String? preferredMode,
    bool? consentResearch,
  }) async {
    final response = await http.patch(
      _uri('/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (preferredMode != null) 'preferred_mode': preferredMode,
        if (consentResearch != null) 'consent_research': consentResearch,
      }),
    );
    final body = _decode(response);
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(_uri('/users/$id'));
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Request failed (${response.statusCode})');
    }
  }
}
