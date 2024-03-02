import 'package:frontend/models/user.dart';
import 'package:frontend/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playlist.g.dart';

@JsonSerializable()
class Playlist {
  int id;
  String name;
  String userId;
  User user;
  List<Track> tracks;

  Playlist({
    required this.id,
    required this.name,
    required this.userId,
    required this.user,
    required this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

  // static fromJson(playlist) {
  //   return Playlist(
  //     id: playlist['id'],
  //     name: playlist['name'],
  //     userId: playlist['userId'],
  //     user: playlist['user'] != null ? User.fromJson(playlist['user']) : null,
  //     tracks: List<Track>.from(playlist['tracks'].map((track) => Track.fromJson(track))),
  //   );
  // }
}

class PlaylistTrack {
  int id;
  int playlistId;
  Playlist playlist;
  int trackId;
  Track track;

  PlaylistTrack({
    required this.id,
    required this.playlistId,
    required this.playlist,
    required this.trackId,
    required this.track,
  });
}
