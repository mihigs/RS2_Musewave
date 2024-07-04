// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHistoryEntry _$SearchHistoryEntryFromJson(Map<String, dynamic> json) =>
    SearchHistoryEntry(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      searchTerm: json['searchTerm'] as String,
      searchDate: DateTime.parse(json['searchDate'] as String),
    );

Map<String, dynamic> _$SearchHistoryEntryToJson(SearchHistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'searchTerm': instance.searchTerm,
      'searchDate': instance.searchDate.toIso8601String(),
    };
