import 'package:frontend/models/base/base_entity.dart';
import 'package:frontend/models/constants/mood_types.dart';
import 'package:frontend/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mood_tracker.g.dart';

@JsonSerializable()
class MoodTracker extends BaseEntity {
  String userId;
  User user;
  String? description;
  DateTime recordDate;
  MoodType moodType;

  MoodTracker(
      {required super.id,
      required super.createdAt,
      required super.updatedAt,
      required this.userId,
      required this.user,
      required this.recordDate,
      required this.moodType,
      this.description});

  factory MoodTracker.fromJson(Map<String, dynamic> json) =>
      _$MoodTrackerFromJson(json);

  Map<String, dynamic> toJson() => _$MoodTrackerToJson(this);
}
