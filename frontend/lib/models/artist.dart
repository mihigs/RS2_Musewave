import 'package:frontend/models/album.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/models/user.dart';

class Artist {
  String userId;
  User user;
  List<Album> albums;
  List<Track> tracks;

  Artist({
    required this.userId,
    required this.user,
    required this.albums,
    required this.tracks,
  });

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
