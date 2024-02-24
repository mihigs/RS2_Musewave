import 'package:frontend/models/album.dart';
import 'package:frontend/models/like.dart';
import 'package:frontend/models/genre.dart';

class Track {
  String title;
  int duration;
  int? albumId;
  Album? album;
  List<Like>? likes;
  int? genreId;
  Genre? genre;

  Track({
    required this.title,
    required this.duration,
    this.albumId,
    this.album,
    this.likes,
    this.genreId,
    this.genre,
  });
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
