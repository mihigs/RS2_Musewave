import 'package:frontend/models/base/base_entity.dart';
import 'package:frontend/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class Artist extends BaseEntity {
  String? userId;
  String? jamendoArtistId;
  String? artistImageUrl;
  User? user;

  Artist({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.jamendoArtistId,
    required this.artistImageUrl,
    required this.userId,
    required this.user,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
  
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
