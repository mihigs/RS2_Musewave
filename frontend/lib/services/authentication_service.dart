import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // For decoding JWT tokens

class AuthenticationService {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  AuthenticationService({required this.baseUrl, required this.secureStorage});

  Future<UserLoginResponse> login(String email, String password) async {
    UserLoginResponse result = new UserLoginResponse();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/User/login'),
        body: jsonEncode({'Email': email, 'Password': password}),
        headers: {'Content-Type': 'application/json'},
      );


      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'] as String;
        await secureStorage.write(key: 'access_token', value: token);
        result.token = token;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        result.error = 'Email or password is incorrect';
      } else {
        result.error = 'An error occurred';
      }
    } catch (e) {
      // Handle network errors
      rethrow;
    }

    return result;
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'access_token');
  }

  bool isTokenValid(String token) {
    return !JwtDecoder.isExpired(token);
  }
}

class UserLoginResponse {
  String? token;
  String? error;

  UserLoginResponse({this.token, this.error});
}
