import 'package:frontend/models/artist.dart';
import 'package:frontend/models/track.dart';

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
}
