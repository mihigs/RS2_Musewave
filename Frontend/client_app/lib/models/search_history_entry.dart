import 'package:frontend/models/base/base_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_history_entry.g.dart';

@JsonSerializable()
class SearchHistoryEntry extends BaseEntity {
  String searchTerm;
  DateTime searchDate;

  SearchHistoryEntry({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.searchTerm,
    required this.searchDate,
  });

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json) => _$SearchHistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$SearchHistoryEntryToJson(this);
}
