import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/language.dart';
import 'package:frontend/services/base/api_service.dart';

class LanguageService extends ApiService {
  final FlutterSecureStorage secureStorage;

  LanguageService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<List<Language>> getAllLanguages() async {
    try {
      final response = await httpGet('User/GetAllLanguages');

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to a Language
      final List<Language> result = List.empty(growable: true);

      for (var item in data) {
        result.add(Language.fromJson(item));
      }

      return result;
    } on Exception {
      rethrow;
    }
  }

  Future<void> updatePreferedLanguage(int languageId) async {
    try {
      await httpPost('User/UpdatePreferedLanguage', { 'languageId': languageId });
    } on Exception {
      rethrow;
    }
  }

}
