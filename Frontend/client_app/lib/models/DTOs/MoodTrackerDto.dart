import 'package:frontend/models/constants/mood_types.dart';

class MoodTrackerDto {
  final String userId;
  final String? description;
  final DateTime recordDate;
  final MoodType moodType;

  MoodTrackerDto(
      {required this.userId,
      required this.recordDate,
      required this.moodType,
      this.description});

  factory MoodTrackerDto.fromJson(Map<String, dynamic> json) {
    return MoodTrackerDto(
      userId: json['userId'],
      description: json['description'],
      recordDate: json['recordDate'],
      moodType: json['moodType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'description': description,
      'recordDate': recordDate,
      'moodType': moodType,
    };
  }
}
