import 'package:frontend/models/artist.dart';
import 'package:frontend/models/track.dart';

class Album {
  String title;
  int artistId;
  Artist artist;
  List<Track> tracks;

  Album({
    this.title,
    this.artistId,
    this.artist,
    this.tracks,
    });
}
