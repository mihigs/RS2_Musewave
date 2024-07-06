import 'package:frontend/models/artist.dart';
import 'package:frontend/models/base/base_entity.dart';
import 'package:frontend/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class Album extends BaseEntity{
  String title;
  int artistId;
  Artist? artist;
  List<Track> tracks;
  String? coverImageUrl;

  Album({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.title,
    required this.artistId,
    required this.artist,
    required this.tracks,
    this.coverImageUrl,
  });

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}
