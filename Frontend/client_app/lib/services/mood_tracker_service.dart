import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/DTOs/Queries/MoodTrackerQuery.dart';
import 'package:frontend/models/constants/mood_types.dart';
import 'package:frontend/models/mood_tracker.dart';
import 'package:frontend/services/base/api_service.dart';

class MoodTrackerService extends ApiService {
  final FlutterSecureStorage secureStorage;

  MoodTrackerService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<List<MoodTracker>> getMoodTrackers() async {
    try {
      MoodTrackerQuery query = MoodTrackerQuery();
      final queryParams = query.toQueryParameters();
      final response = await httpGet('MoodTracker/GetMoodTrackers',
          queryParams: queryParams);

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to a MoodTracker
      final List<MoodTracker> result = List.empty(growable: true);

      for (var item in data) {
        result.add(MoodTracker.fromJson(item));
      }

      return result;
    } on Exception {
      rethrow;
    }
  }

  Future<void> recordMood(String userId, MoodType moodType, DateTime recordDate,
      String? description) async {
    try {
      await httpPost('MoodTracker/RecordMood', {
        'userId': userId,
        'moodType': moodType.index,
        'recordDate': recordDate.toIso8601String(),
        'description': description
      });
    } on Exception {
      rethrow;
    }
  }
}
