import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart'; // For decoding JWT tokens

class ApiService {
  final FlutterSecureStorage secureStorage;
  final String baseUrl = const String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:8080/api');

  ApiService({required this.secureStorage});

  dynamic httpGet(String endpoint, {List<String> queryParams = const []}) async {
    final token = await getTokenFromStorage();
    final response = await http.get(
      Uri.parse(
          '$baseUrl/$endpoint${queryParams.isNotEmpty ? '/${queryParams.join('&')}' : ""}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _parseResponse(response);
  }


  Future<dynamic> httpPost<T>(String endpoint, T data) async {
    final token = await getTokenFromStorage();
    if (token == null) {
      // Redirect to login
      return null;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _parseResponse(response);
  }

  Future<dynamic> httpDelete(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final token = await getTokenFromStorage();
    if (token == null) {
      // Redirect to login
      return null;
    }

    final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _parseResponse(response);
  }

  Future<dynamic> httpPut<T>(String endpoint, T data) async {
    final token = await getTokenFromStorage();
    if (token == null) {
      // Redirect to login
      return null;
    }
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _parseResponse(response);
  }

  Future<dynamic> _parseResponse(http.Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = await jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }
  
  Future<String?> getTokenFromStorage() async {
    String? token = await secureStorage.read(key: 'access_token');
    if (token != null && isTokenValid(token)) {
      return token;
    }
    return null;
  }

  Future<String?> getUserIdFromStorage() async {
    String? userId = await secureStorage.read(key: 'user_id');
    return userId;
  }

  bool isTokenValid(String token) {
    bool isTokenValid = !JwtDecoder.isExpired(token);
    return isTokenValid;
  }
}
