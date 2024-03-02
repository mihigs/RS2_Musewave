import 'package:frontend/models/album.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class Artist {
  String userId;
  User user;

  Artist({
    required this.userId,
    required this.user,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  // A necessary instance method for converting a Artist instance to a map.
  // Pass the map to the generated `_$ArtistToJson()` method.
  // The method is named after the source class, in this case, Artist.
  Map<String, dynamic> toJson() => _$ArtistToJson(this);

  // static fromJson(item) {
  //   return Artist(
  //     userId: item['userId'],
  //     user: User.fromJson(item['user']),
  //     // albums: List<Album>.from(item['Albums'].map((album) => Album.fromJson(album))),
  //     // tracks: List<Track>.from(item['Tracks'].map((track) => Track.fromJson(track))),
  //   );
  // }

  // factory Artist.fromJson(Map<String, dynamic> json) {
  //   return Artist(
  //     userId: json['UserId'],
  //     user: User.fromJson(json['User']),
  //     albums: (json['Albums'] as List).map((i) => Album.fromJson(i)).toList(),
  //     tracks: (json['Tracks'] as List).map((i) => Track.fromJson(i)).toList(),
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'UserId': userId,
  //     'User': user.toJson(),
  //     'Albums': albums.map((i) => i.toJson()).toList(),
  //     'Tracks': tracks.map((i) => i.toJson()).toList(),
  //   };
  // }
}
