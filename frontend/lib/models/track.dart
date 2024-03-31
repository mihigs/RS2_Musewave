import 'package:frontend/models/album.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/models/base/base_entity.dart';
import 'package:frontend/models/like.dart';
import 'package:frontend/models/genre.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

@JsonSerializable()
class Track extends BaseEntity {
  String title;
  int duration;
  int? albumId;
  Album? album;
  List<Like>? likes;
  int? genreId;
  Genre? genre;
  int? artistId;
  Artist? artist;
  String? filePath;
  String? signedUrl;
  bool? isLiked;
  String? imageUrl;
  String? jamendoId;

  Track({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.title,
    required this.duration,
    this.albumId,
    this.album,
    this.likes,
    this.genreId,
    this.genre,
    required this.artist,
    required this.artistId,
    this.filePath,
    this.signedUrl,
    this.isLiked,
    this.imageUrl,
    this.jamendoId,
  });

    // A necessary factory constructor for creating a new Track instance
  // from a map. Pass the map to the generated `_$TrackFromJson()` constructor.
  // The constructor is named after the source class, in this case, Track.
  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  // A necessary instance method for converting a Track instance to a map.
  // Pass the map to the generated `_$TrackToJson()` method.
  // The method is named after the source class, in this case, Track.
  Map<String, dynamic> toJson() => _$TrackToJson(this);
}

class TrackGenre {
  int id;
  int trackId;
  Track track;
  int genreId;
  Genre genre;

  TrackGenre({
    required this.id,
    required this.trackId,
    required this.track,
    required this.genreId,
    required this.genre,
  });
}
