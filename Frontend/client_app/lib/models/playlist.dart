import 'package:frontend/models/base/base_entity.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playlist.g.dart';

@JsonSerializable()
class Playlist extends BaseEntity {
  String name;
  String userId;
  User? user;
  bool isPublic;
  bool isExploreWeekly;
  List<Track> tracks = [];

  Playlist({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.userId,
    this.user,
    required this.isPublic,
    required this.isExploreWeekly,
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
  //     playlistTracks: List<Track>.from(playlist['playlistTracks'].map((track) => Track.fromJson(track))),
  //   );
  // }
}

class PlaylistTrack {
  int playlistId;
  int trackId;
  Track track;

  PlaylistTrack({
    required this.playlistId,
    required this.trackId,
    required this.track,
  });
}
