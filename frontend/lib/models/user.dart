import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/like.dart';
import 'package:frontend/models/artist.dart';

class User {
  String id;
  String? userName;
  String? normalizedUserName;
  String? email;
  String? normalizedEmail;
  bool emailConfirmed;
  String? passwordHash;
  String? securityStamp;
  String? concurrencyStamp;
  String? phoneNumber;
  bool phoneNumberConfirmed;
  bool twoFactorEnabled;
  DateTime? lockoutEnd;
  bool lockoutEnabled;
  int accessFailedCount;
  List<Playlist> playlists;
  List<Like> likes;
  Artist? artist;
  int? artistId;

  User({
    required this.id,
    this.userName,
    this.normalizedUserName,
    this.email,
    this.normalizedEmail,
    required this.emailConfirmed,
    this.passwordHash,
    this.securityStamp,
    this.concurrencyStamp,
    this.phoneNumber,
    required this.phoneNumberConfirmed,
    required this.twoFactorEnabled,
    this.lockoutEnd,
    required this.lockoutEnabled,
    required this.accessFailedCount,
    required this.playlists,
    required this.likes,
    this.artist,
    this.artistId,
  });
}
