import 'package:flutter/material.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/album_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/navigation_menu.dart';
import 'package:frontend/widgets/search_bar.dart';
import 'package:frontend/widgets/search_results.dart';
import 'package:get_it/get_it.dart';

class SearchPage extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  final AlbumService albumService = GetIt.I<AlbumService>();

  SearchPage({super.key});


  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Track>> likedTracksFuture;
  late FocusNode _focusNode;
  bool isSearching = false;
  late Future<List<Track>> _tracksFuture;
  late Future<List<Album>> _albumsFuture;

  void handleSubmitted(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for $value ...')),
    );

    setState(() {
      _tracksFuture = widget.tracksService.getTracksByName(value);
      _albumsFuture = widget.albumService.getAlbumsByTitle(value);
      _tracksFuture.then((value) {
        var temp2 = value;
        return temp2;
      });
      _albumsFuture.then((value) {
        var temp2 = value;
        return temp2;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    _tracksFuture = Future.value([]);
    _albumsFuture = Future.value([]);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10, 35, 10, 10), // left, top, right, bottom
            child: SearchBarWidget(
              focusNode: _focusNode,
              key: null,
              onSubmitted: handleSubmitted,
            ),
          ),
          Expanded(
            child: SearchResults(
                tracksFuture: _tracksFuture,
                albumsFuture: _albumsFuture,
            ),
          ),
        ],
      );
  }
}
