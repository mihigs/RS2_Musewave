import 'package:frontend/models/artist.dart';
import 'package:frontend/models/base/base_entity.dart';
import 'package:frontend/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'language.g.dart';

@JsonSerializable()
class Language extends BaseEntity{
  String name;
  String code;

  Language({
    required super.id,
    required this.name,
    required this.code,
    required super.createdAt,
    required super.updatedAt,
  });

  factory Language.fromJson(Map<String, dynamic> json) => _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);
}
