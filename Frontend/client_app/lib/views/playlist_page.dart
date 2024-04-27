import 'package:flutter/material.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/widgets/collection/collection_list.dart';

class PlaylistPage extends StatelessWidget {
  int? _playlistId;
  bool? isExploreWeekly = false;

  get isLikedPlaylist => _playlistId == null;

  PlaylistPage({super.key, int? playlistId, this.isExploreWeekly = false}) : _playlistId = playlistId;


  @override
  Widget build(BuildContext context) {
    return Container(
      child: CollectionList(
        contextId: _playlistId,
        streamingContextType: isLikedPlaylist ? StreamingContextType.LIKED : StreamingContextType.PLAYLIST,
        isExploreWeekly: isExploreWeekly!
      ),
    );
  }
}
