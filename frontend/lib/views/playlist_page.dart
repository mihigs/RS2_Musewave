import 'package:flutter/material.dart';
import 'package:frontend/widgets/collection/collection_list.dart';

class PlaylistPage extends StatelessWidget {
  int _playlistId;

  PlaylistPage({super.key, required int playlistId}) : _playlistId = playlistId;


  @override
  Widget build(BuildContext context) {
    return Container(
      child: CollectionList(
        contextId: _playlistId,
        contextType: "playlist",
      ),
    );
  }
}
