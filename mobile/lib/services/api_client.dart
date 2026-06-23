import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const _headers = {'Content-Type': 'application/json'};

  Uri uri(String path) => Uri.parse('${dotenv.env['API_BASE_URL']}$path');

  Future<Map<String, dynamic>> getJson(String path) async {
    return _decode(await http.get(uri(path)));
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _decode(
      await http.post(uri(path), headers: _headers, body: jsonEncode(body)),
    );
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _decode(
      await http.patch(uri(path), headers: _headers, body: jsonEncode(body)),
    );
  }

  Future<void> deleteJson(String path) async {
    _checkStatus(await http.delete(uri(path)));
  }

  Map<String, dynamic> _decode(http.Response response) {
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        body['error'] ?? 'Request failed (${response.statusCode})',
      );
    }
  }
}
