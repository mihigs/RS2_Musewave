// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
      title: json['title'] as String,
      artistId: json['artistId'] as int,
      artist: Artist.fromJson(json['artist'] as Map<String, dynamic>),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'title': instance.title,
      'artistId': instance.artistId,
      'artist': instance.artist,
      'tracks': instance.tracks,
    };
