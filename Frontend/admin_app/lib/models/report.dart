import 'package:admin_app/models/base/base_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonSerializable()
class Report extends BaseEntity {
  int newMusewaveTrackCount;
  int newJamendoTrackCount;
  int newUserCount;
  int newArtistCount;
  int dailyLoginCount;
  int monthlyJamendoApiActivity;
  int monthlyTimeListened;
  double monthlyDonationsAmount;
  int monthlyDonationsCount;
  int reportMonth;
  int reportYear;
  DateTime reportDate;

  Report({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.newMusewaveTrackCount,
    required this.newJamendoTrackCount,
    required this.newUserCount,
    required this.newArtistCount,
    required this.dailyLoginCount,
    required this.monthlyJamendoApiActivity,
    required this.monthlyTimeListened,
    required this.monthlyDonationsAmount,
    required this.monthlyDonationsCount,
    required this.reportMonth,
    required this.reportYear,
    required this.reportDate,
  });

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
