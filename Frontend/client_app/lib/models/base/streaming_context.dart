import 'package:frontend/models/track.dart';

enum StreamingContextType { RADIO, ALBUM, PLAYLIST, JAMENDO, LIKED, WEEKLY }

class StreamingContext {
  Track track;
  final int? contextId;
  StreamingContextType type;
  List<int> trackHistoryIds = [];
  Duration timeListened = Duration.zero;

  StreamingContext(this.track, this.contextId, this.type);

  void addTimeListened(Duration duration) {
    timeListened += duration;
  }

  void resetTimeListened() {
    timeListened = Duration.zero;
  }
}
