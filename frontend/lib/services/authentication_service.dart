import 'dart:convert';
import 'package:frontend/models/base/logged_in_state_info.dart';
import 'package:frontend/services/base/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthenticationService extends ApiService {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;
  final LoggedInStateInfo loggedInState = new LoggedInStateInfo();

  AuthenticationService({required this.baseUrl, required this.secureStorage}) : super(secureStorage: secureStorage);

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
        loggedInState.login();
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
    loggedInState.logout();
  }

  LoggedInStateInfo getLoggedInState() {
    return loggedInState;
  }
}

class UserLoginResponse {
  String? token;
  String? error;

  UserLoginResponse({this.token, this.error});
}
