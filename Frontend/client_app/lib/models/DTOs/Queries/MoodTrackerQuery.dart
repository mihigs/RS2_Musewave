import 'package:frontend/models/constants/mood_types.dart';

class MoodTrackerQuery {
  final String? userId;
  final DateTime? recordDate;
  final MoodType? moodType;

  MoodTrackerQuery({this.userId, this.recordDate, this.moodType});

  List<String> toQueryParameters() {
    List<String> params = [];
    if (userId != null) params.add('?userId=$userId');
    if (recordDate != null) params.add('?recordDate=$recordDate');
    if (moodType != null) params.add('?moodType=$moodType');
    return params;
  }
}
