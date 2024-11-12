// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      newMusewaveTrackCount: (json['newMusewaveTrackCount'] as num).toInt(),
      newJamendoTrackCount: (json['newJamendoTrackCount'] as num).toInt(),
      newUserCount: (json['newUserCount'] as num).toInt(),
      newArtistCount: (json['newArtistCount'] as num).toInt(),
      dailyLoginCount: (json['dailyLoginCount'] as num).toInt(),
      monthlyJamendoApiActivity:
          (json['monthlyJamendoApiActivity'] as num).toInt(),
      monthlyTimeListened: (json['monthlyTimeListened'] as num).toInt(),
      monthlyDonationsAmount:
          (json['monthlyDonationsAmount'] as num).toDouble(),
      monthlyDonationsCount: (json['monthlyDonationsCount'] as num).toInt(),
      reportMonth: (json['reportMonth'] as num).toInt(),
      reportYear: (json['reportYear'] as num).toInt(),
      reportDate: DateTime.parse(json['reportDate'] as String),
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'newMusewaveTrackCount': instance.newMusewaveTrackCount,
      'newJamendoTrackCount': instance.newJamendoTrackCount,
      'newUserCount': instance.newUserCount,
      'newArtistCount': instance.newArtistCount,
      'dailyLoginCount': instance.dailyLoginCount,
      'monthlyJamendoApiActivity': instance.monthlyJamendoApiActivity,
      'monthlyTimeListened': instance.monthlyTimeListened,
      'monthlyDonationsAmount': instance.monthlyDonationsAmount,
      'monthlyDonationsCount': instance.monthlyDonationsCount,
      'reportMonth': instance.reportMonth,
      'reportYear': instance.reportYear,
      'reportDate': instance.reportDate.toIso8601String(),
    };
