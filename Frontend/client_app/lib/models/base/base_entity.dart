import 'package:json_annotation/json_annotation.dart';

part 'base_entity.g.dart';

@JsonSerializable()
class BaseEntity{
  int id;
  DateTime createdAt;
  DateTime updatedAt;

  BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BaseEntity.fromJson(Map<String, dynamic> json) => _$BaseEntityFromJson(json);
  
  Map<String, dynamic> toJson() => _$BaseEntityToJson(this);
}