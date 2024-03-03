import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/like.dart';
import 'package:frontend/models/artist.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String id;
  String userName;
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
    required this.userName,
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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // A necessary instance method for converting a User instance to a map.
  // Pass the map to the generated `_$UserToJson()` method.
  // The method is named after the source class, in this case, User.
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // static fromJson(item) {
  //   User result = User(
  //     id: item['id'],
  //     userName: item['userName'],
  //     normalizedUserName: item['normalizedUserName'],
  //     email: item['email'],
  //     normalizedEmail: item['normalizedEmail'],
  //     emailConfirmed: item['emailConfirmed'],
  //     passwordHash: item['passwordHash'],
  //     securityStamp: item['securityStamp'],
  //     concurrencyStamp: item['concurrencyStamp'],
  //     phoneNumber: item['phoneNumber'],
  //     phoneNumberConfirmed: item['phoneNumberConfirmed'],
  //     twoFactorEnabled: item['twoFactorEnabled'],
  //     lockoutEnd: item['lockoutEnd'],
  //     lockoutEnabled: item['lockoutEnabled'],
  //     accessFailedCount: item['accessFailedCount'],
  //     playlists: List<Playlist>.from(item['playlists'].map((playlist) => Playlist.fromJson(playlist))),
  //     likes: List<Like>.from(item['likes'].map((like) => Like.fromJson(like))),
  //     artist: item['artist'] != null ? Artist.fromJson(item['artist']) : null,
  //     artistId: item['artistId'],
  //   );

  //   return result;
  // }
}
