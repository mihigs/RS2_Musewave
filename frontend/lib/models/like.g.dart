// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Like _$LikeFromJson(Map<String, dynamic> json) => Like(
      userId: json['userId'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      trackId: json['trackId'] as int,
      track: Track.fromJson(json['track'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LikeToJson(Like instance) => <String, dynamic>{
      'userId': instance.userId,
      'user': instance.user,
      'trackId': instance.trackId,
      'track': instance.track,
    };
