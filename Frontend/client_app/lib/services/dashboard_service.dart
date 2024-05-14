import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/DTOs/HomepageDetailsDto.dart';
import 'package:frontend/services/base/api_service.dart';

class DashboardService extends ApiService {
  final FlutterSecureStorage secureStorage;

  DashboardService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<HomepageDetailsDto> GetHomepageDetails() async {
    try {
      final response = await httpGet('User/GetHomepageDetails');

      HomepageDetailsDto result = HomepageDetailsDto.fromJson(response['data']);

      return result;
    } on Exception {
      rethrow;
    }
  }
}