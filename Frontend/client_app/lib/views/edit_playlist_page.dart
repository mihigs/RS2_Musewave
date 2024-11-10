import 'package:flutter/material.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/widgets/collection/edit_collection_list.dart';

class EditPlaylistPage extends StatelessWidget {
  final int? _playlistId;
  final bool isExploreWeekly;

  bool get isLikedPlaylist => _playlistId == null;

  EditPlaylistPage({
    Key? key,
    int? playlistId,
    this.isExploreWeekly = false,
  })  : _playlistId = playlistId,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: EditCollectionList(
        contextId: _playlistId,
        streamingContextType: isLikedPlaylist
            ? StreamingContextType.LIKED
            : StreamingContextType.PLAYLIST,
        isExploreWeekly: isExploreWeekly,
      ),
    );
  }
}
