import 'package:frontend/models/user.dart';
import 'package:frontend/models/track.dart';

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
