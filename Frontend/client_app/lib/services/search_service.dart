import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/DTOs/SearchQueryResults.dart';
import 'package:frontend/models/search_history_entry.dart';
import 'package:frontend/services/base/api_service.dart';

class SearchService extends ApiService {
  final FlutterSecureStorage secureStorage;

  SearchService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<SearchQueryResults> query(String searchTerm) async {
    try {
      final response = await httpGet('Search/Query?searchQuery=$searchTerm');
      
      return SearchQueryResults.fromJson(response['data']);

    } on Exception {
      rethrow;
    }
  }

  Future<List<SearchHistoryEntry>> getSearchHistory() async {
    try {
      final response = await httpGet('Search/GetSearchHistory');

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to a SearchHistoryEntry
      final List<SearchHistoryEntry> result = List.empty(growable: true);

      for (var item in data) {
        result.add(SearchHistoryEntry.fromJson(item));
      }

      return result;
    } on Exception {
      rethrow;
    }
  }

  Future<bool> removeSearchHistory(int id) async {
    try {
      await httpPost('Search/RemoveSearchHistory?searchHistoryId=$id', null);
      return true;
    } on Exception {
      return false;
    }
  }
}
