// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String,
      duration: json['duration'] as int,
      albumId: json['albumId'] as int?,
      album: json['album'] == null
          ? null
          : Album.fromJson(json['album'] as Map<String, dynamic>),
      likes: (json['likes'] as List<dynamic>?)
          ?.map((e) => Like.fromJson(e as Map<String, dynamic>))
          .toList(),
      genreId: json['genreId'] as int?,
      genre: json['genre'] == null
          ? null
          : Genre.fromJson(json['genre'] as Map<String, dynamic>),
      artist: Artist.fromJson(json['artist'] as Map<String, dynamic>),
      artistId: json['artistId'] as int,
      filePath: json['filePath'] as String?,
      signedUrl: json['signedUrl'] as String?,
    );

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'duration': instance.duration,
      'albumId': instance.albumId,
      'album': instance.album,
      'likes': instance.likes,
      'genreId': instance.genreId,
      'genre': instance.genre,
      'artistId': instance.artistId,
      'artist': instance.artist,
      'filePath': instance.filePath,
      'signedUrl': instance.signedUrl,
    };
