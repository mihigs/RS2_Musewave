import 'package:frontend/models/track.dart';

enum StreamingContextType { RADIO, ALBUM, PLAYLIST }

class StreamingContext {
  final Track track;
  final int? contextId;
  final StreamingContextType type;
  List<int> trackHistoryIds = [];

  StreamingContext(this.track, this.contextId, this.type);
}

