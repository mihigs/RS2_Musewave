import 'package:admin_app/models/base/base_entity.dart';
import 'package:admin_app/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class Artist extends BaseEntity {
  String? userId;
  User? user;

  Artist({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.user,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
  
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
