import 'dart:convert';
import 'package:frontend/models/base/logged_in_state_info.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/base/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/signalr_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthenticationService extends ApiService {
  final FlutterSecureStorage secureStorage;
  final LoggedInStateInfo loggedInState = new LoggedInStateInfo();
  final SignalRService signalrService = GetIt.I<SignalRService>();

  AuthenticationService({required this.secureStorage}) : super(secureStorage: secureStorage);

  Future<UserLoginResponse> login(String email, String password) async {
    UserLoginResponse result = new UserLoginResponse();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/User/Login'),
        body: jsonEncode({'Email': email, 'Password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        const String NameIdentifierClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
        final token = jsonDecode(response.body)['token'] as String;
        final userId = JwtDecoder.decode(token)[NameIdentifierClaimType] as String;
        final languageCode = jsonDecode(response.body)['languageCode'] as String;
        // Initialize SignalR connection
        signalrService.initializeConnection(token);
        // Store data in secure storage
        await secureStorage.write(key: 'access_token', value: token);
        await secureStorage.write(key: 'user_id', value: userId);
        await secureStorage.write(key: 'language_code', value: languageCode);
        result.token = token;
        // Update logged in state
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

  Future<String?> checkLocalStorageForToken() async {
    final token = await getTokenFromStorage();
    if (token != null) {
      loggedInState.login();
      return token;
    }
    loggedInState.logout();
    return null;
  }

  Future<User> getUserDetails() async {
    try {
      final response = await httpGet('User/GetUserDetails');
      return User.fromJson(response['data']);
    } on Exception {
      loggedInState.logout();
      rethrow;
    }
  }
}

class UserLoginResponse {
  String? token;
  String? error;

  UserLoginResponse({this.token, this.error});
}
