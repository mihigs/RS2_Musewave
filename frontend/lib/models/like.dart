import 'package:frontend/models/base/base_entity.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'like.g.dart';

@JsonSerializable()
class Like extends BaseEntity {
  String userId;
  User user;
  int trackId;
  Track track;

  Like({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.user,
    required this.trackId,
    required this.track,
  });

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);

  Map<String, dynamic> toJson() => _$LikeToJson(this);

  // static fromJson(like) {
  //   if (like is! Map<String, dynamic>) {
  //     return null;
  //   }
  //   return Like(
  //     userId: like['userId'],
  //     user: like['user'],
  //     trackId: like['trackId'],
  //     track: like['track'],
  //   );
  // }
}
