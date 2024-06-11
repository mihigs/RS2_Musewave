import 'package:frontend/models/base/base_entity.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment extends BaseEntity {
  String userId;
  User? user;
  int trackId;
  Track? track;
  String text;

  Comment({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    this.user,
    required this.trackId,
    this.track,
    required this.text,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
