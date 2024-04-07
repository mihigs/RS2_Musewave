import 'package:frontend/models/user.dart';

class UserPlaylistsDto {
    int id;
    String name;
    String userId;
    User? user;
    bool isPublic;
    bool isExploreWeekly;
    List<int> trackIds = [];

  UserPlaylistsDto({
    required this.id,
    required this.name,
    required this.userId,
    this.user,
    required this.isPublic,
    required this.isExploreWeekly,
    required this.trackIds,
  });

  factory UserPlaylistsDto.fromJson(Map<String, dynamic> json) {
    return UserPlaylistsDto(
      id: json['id'],
      name: json['name'],
      userId: json['userId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      isPublic: json['isPublic'],
      isExploreWeekly: json['isExploreWeekly'],
      trackIds: List<int>.from(json['trackIds'].map((trackId) => trackId)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'user': user,
      'isPublic': isPublic,
      'isExploreWeekly': isExploreWeekly,
      'trackIds': trackIds,
    };
  }
}