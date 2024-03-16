import 'package:flutter/material.dart';
import 'package:frontend/widgets/collection/collection_list.dart';

class AlbumPage extends StatelessWidget {
  int _albumId;

  AlbumPage({super.key, required int albumId}) : _albumId = albumId;


  @override
  Widget build(BuildContext context) {
    return Container(
      child: CollectionList(
        contextId: _albumId,
        contextType: "album",
      ),
    );
  }
}
