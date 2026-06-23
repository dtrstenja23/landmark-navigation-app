import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  Uri uri(String path) => Uri.parse('${dotenv.env['API_BASE_URL']}$path');

  Map<String, dynamic> decode(http.Response response) {
    checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Request failed (${response.statusCode})');
    }
  }
}
