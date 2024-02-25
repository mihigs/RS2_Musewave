import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/track.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart'; // For decoding JWT tokens

class ApiService {
  final FlutterSecureStorage secureStorage;
  final String _baseUrl = 'https://10.0.2.2:7074/api';

  ApiService({required this.secureStorage});

  dynamic httpGet(String endpoint, {List<String> queryParams = const []}) async {
    final token = await getTokenFromStorage();
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/$endpoint${queryParams.isNotEmpty ? '/${queryParams.join('&')}' : ""}'),
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
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _parseResponse(response);
  }
  
  Future<dynamic> _parseResponse(http.Response response) async {
    if (response.statusCode == 200) {
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

  bool isTokenValid(String token) {
    bool isTokenValid = !JwtDecoder.isExpired(token);
    return isTokenValid;
  }
}
