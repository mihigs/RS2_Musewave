// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
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
    );

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'title': instance.title,
      'duration': instance.duration,
      'albumId': instance.albumId,
      'album': instance.album,
      'likes': instance.likes,
      'genreId': instance.genreId,
      'genre': instance.genre,
      'artistId': instance.artistId,
      'artist': instance.artist,
    };
