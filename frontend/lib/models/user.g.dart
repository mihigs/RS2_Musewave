// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      userName: json['userName'] as String,
      normalizedUserName: json['normalizedUserName'] as String?,
      email: json['email'] as String?,
      normalizedEmail: json['normalizedEmail'] as String?,
      emailConfirmed: json['emailConfirmed'] as bool,
      passwordHash: json['passwordHash'] as String?,
      securityStamp: json['securityStamp'] as String?,
      concurrencyStamp: json['concurrencyStamp'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      phoneNumberConfirmed: json['phoneNumberConfirmed'] as bool,
      twoFactorEnabled: json['twoFactorEnabled'] as bool,
      lockoutEnd: json['lockoutEnd'] == null
          ? null
          : DateTime.parse(json['lockoutEnd'] as String),
      lockoutEnabled: json['lockoutEnabled'] as bool,
      accessFailedCount: json['accessFailedCount'] as int,
      playlists: (json['playlists'] as List<dynamic>)
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList(),
      likes: (json['likes'] as List<dynamic>)
          .map((e) => Like.fromJson(e as Map<String, dynamic>))
          .toList(),
      artist: json['artist'] == null
          ? null
          : Artist.fromJson(json['artist'] as Map<String, dynamic>),
      artistId: json['artistId'] as int?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'normalizedUserName': instance.normalizedUserName,
      'email': instance.email,
      'normalizedEmail': instance.normalizedEmail,
      'emailConfirmed': instance.emailConfirmed,
      'passwordHash': instance.passwordHash,
      'securityStamp': instance.securityStamp,
      'concurrencyStamp': instance.concurrencyStamp,
      'phoneNumber': instance.phoneNumber,
      'phoneNumberConfirmed': instance.phoneNumberConfirmed,
      'twoFactorEnabled': instance.twoFactorEnabled,
      'lockoutEnd': instance.lockoutEnd?.toIso8601String(),
      'lockoutEnabled': instance.lockoutEnabled,
      'accessFailedCount': instance.accessFailedCount,
      'playlists': instance.playlists,
      'likes': instance.likes,
      'artist': instance.artist,
      'artistId': instance.artistId,
    };
