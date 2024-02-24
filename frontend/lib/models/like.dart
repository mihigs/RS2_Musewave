import 'package:frontend/models/user.dart';
import 'package:frontend/models/track.dart';

class Like {
  String userId;
  User user;
  int trackId;
  Track track;

  Like({
    required this.userId,
    required this.user,
    required this.trackId,
    required this.track,
  });
}
