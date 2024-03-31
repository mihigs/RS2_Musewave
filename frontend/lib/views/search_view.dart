import 'package:flutter/material.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/album_service.dart';
import 'package:frontend/services/artist_service.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/search_bar.dart';
import 'package:frontend/widgets/search_results.dart';
import 'package:get_it/get_it.dart';

class SearchPage extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  final AlbumService albumService = GetIt.I<AlbumService>();
  final ArtistService artistService = GetIt.I<ArtistService>();
  final PlaylistService playlistService = GetIt.I<PlaylistService>();

  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late FocusNode _focusNode;
  bool isSearching = false;
  late Future<List<Track>> _tracksFuture;
  late Future<List<Track>> _jamendoTracksFuture;
  late Future<List<Album>> _albumsFuture;
  late Future<List<Artist>> _artistsFuture;
  late Future<List<Playlist>> _playlistsFuture;
  
  void handleSubmitted(String value) {
    setState(() {
      _tracksFuture = widget.tracksService.getTracksByName(value);
      _jamendoTracksFuture = widget.tracksService.getJamendoTracksByName(value);
      _albumsFuture = widget.albumService.getAlbumsByTitle(value);
      _artistsFuture = widget.artistService.getArtistsByName(value);
      _playlistsFuture = widget.playlistService.getPlaylistsByName(value);
    });
  }


  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    _tracksFuture = Future.value([]);
    _jamendoTracksFuture = Future.value([]);
    _albumsFuture = Future.value([]);
    _artistsFuture = Future.value([]);
    _playlistsFuture = Future.value([]);
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
                jamendoTracksFuture: _jamendoTracksFuture,
                albumsFuture: _albumsFuture,
                artistsFuture: _artistsFuture,
                playlistsFuture: _playlistsFuture
            ),
          ),
        ],
      );
  }
}
