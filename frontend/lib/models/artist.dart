import 'package:frontend/models/album.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/models/user.dart';

class Artist {
  String userId;
  User user;
  List<Album> albums;
  List<Track> tracks;

  Artist({
    this.userId,
    this.user,
    this.albums,
    this.tracks,
  });
}
