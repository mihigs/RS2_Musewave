import 'package:frontend/models/base/base_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genre.g.dart';

@JsonSerializable()
class Genre extends BaseEntity {
  String name;

  Genre({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
  Map<String, dynamic> toJson() => _$GenreToJson(this);
}
