import 'package:flutter/material.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/widgets/collection/collection_list.dart';

class AlbumPage extends StatelessWidget {
  final int _albumId;

  const AlbumPage({super.key, required int albumId}) : _albumId = albumId;


  @override
  Widget build(BuildContext context) {
    return CollectionList(
      contextId: _albumId,
      streamingContextType: StreamingContextType.ALBUM,
    );
  }
}
