import 'package:frontend/models/artist.dart';
import 'package:frontend/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class Album {
  String title;
  int artistId;
  Artist artist;
  List<Track> tracks;

  Album({
    required this.title,
    required this.artistId,
    required this.artist,
    required this.tracks,
  });

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  // A necessary instance method for converting a Album instance to a map.
  // Pass the map to the generated `_$AlbumToJson()` method.
  // The method is named after the source class, in this case, Album.
  Map<String, dynamic> toJson() => _$AlbumToJson(this);

  // static Album fromJson(Map<String, dynamic> item) {
  //   return Album(
  //     title: item['title'] ?? '',
  //     artistId: item['artistId'] ?? '',
  //     artist: Artist.fromJson(item['artist'])!,
  //     tracks: item['tracks'].length
  //         ? List<Track>.from(
  //             item['tracks'].map((track) => Track.fromJson(track)))
  //         : [],
  //   );
  // }
}
