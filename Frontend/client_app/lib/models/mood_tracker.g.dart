// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_tracker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodTracker _$MoodTrackerFromJson(Map<String, dynamic> json) => MoodTracker(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      recordDate: DateTime.parse(json['recordDate'] as String),
      moodType: $enumDecode(_$MoodTypeEnumMap, json['moodType']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$MoodTrackerToJson(MoodTracker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
      'user': instance.user,
      'description': instance.description,
      'recordDate': instance.recordDate.toIso8601String(),
      'moodType': _$MoodTypeEnumMap[instance.moodType]!,
    };

const _$MoodTypeEnumMap = {
  MoodType.HAPPY: 'HAPPY',
  MoodType.SAD: 'SAD',
  MoodType.STRESSED: 'STRESSED',
  MoodType.EXCITED: 'EXCITED',
  MoodType.TIRED: 'TIRED',
};
