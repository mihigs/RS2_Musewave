import 'package:admin_app/models/artist.dart';
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
    this.artist,
    this.artistId,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // A necessary instance method for converting a User instance to a map.
  // Pass the map to the generated `_$UserToJson()` method.
  // The method is named after the source class, in this case, User.
  Map<String, dynamic> toJson() => _$UserToJson(this);

}
