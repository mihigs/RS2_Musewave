import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/DTOs/HomepageDetailsDto.dart';
import 'package:frontend/services/base/api_service.dart';

class DashboardService extends ApiService {
  final FlutterSecureStorage secureStorage;

  DashboardService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<HomepageDetailsDto> GetHomepageDetails() async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final response = await httpGet('User/GetHomepageDetails');
        HomepageDetailsDto result = HomepageDetailsDto.fromJson(response['data']);
        return result;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2)); // Wait before retrying
      }
    }
    throw Exception('Failed to fetch homepage details after $maxRetries attempts');
  }
}