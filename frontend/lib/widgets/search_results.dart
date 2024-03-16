import 'package:flutter/material.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/widgets/result_item_card.dart';
import 'package:go_router/go_router.dart';

class SearchResults extends StatefulWidget {
  final Future<List<Track>> tracksFuture;
  final Future<List<Album>> albumsFuture;
  final Future<List<Artist>> artistsFuture;
  final Future<List<Playlist>> playlistsFuture;

  const SearchResults({
    super.key,
    required this.tracksFuture,
    required this.albumsFuture,
    required this.artistsFuture,
    required this.playlistsFuture,
  });

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  int _tracksToShow = 3;
  int _albumsToShow = 3;
  int _artistsToShow = 3;
  int _playlistsToShow = 3;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        widget.tracksFuture,
        widget.albumsFuture,
        widget.artistsFuture,
        widget.playlistsFuture
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var results = snapshot.data!;
          var tracks = results[0] as List<Track>;
          var albums = results[1] as List<Album>;
          var artists = results[2] as List<Artist>;
          var playlists = results[3] as List<Playlist>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (tracks.isNotEmpty) ...[
                  Container(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Tracks',
                          style: Theme.of(context).textTheme.headline4)),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    padding: const EdgeInsets.all(8.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ...tracks
                          .take(_tracksToShow)
                          .map((track) => GestureDetector(
                            onTap:() => GoRouter.of(context).go('/track/${track.id}/0/0'),
                            child: ResultItemCard(
                                  title: track.title,
                                  subtitle: track.artist.user.userName,
                                ),
                          )),
                    ],
                  ),
                  if (_tracksToShow < tracks.length)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tracksToShow += 8;
                        });
                      },
                      child: Text('Show more'),
                    ),
                ],
                if (albums.isNotEmpty) ...[
                  Container(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Albums',
                          style: Theme.of(context).textTheme.headline4)),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    padding: const EdgeInsets.all(8.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ...albums
                          .take(_albumsToShow)
                          .map((album) => ResultItemCard(
                                title: album.title,
                                subtitle: album.artist.user.userName,
                              )),
                    ],
                  ),
                  if (_albumsToShow < albums.length)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _albumsToShow += 8;
                        });
                      },
                      child: const Text('Show more'),
                    ),
                ],
                if (artists.isNotEmpty) ...[
                  Container(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Artists',
                          style: Theme.of(context).textTheme.headline4)),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    padding: const EdgeInsets.all(8.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ...artists
                          .take(_artistsToShow)
                          .map((artist) => ResultItemCard(
                                title: artist.user.userName,
                              )),
                    ],
                  ),
                  if (_artistsToShow < artists.length)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _artistsToShow += 8;
                        });
                      },
                      child: const Text('Show more'),
                    ),
                ],
                if (playlists.isNotEmpty) ...[
                  Container(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Playlists',
                          style: Theme.of(context).textTheme.headline4)),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    padding: const EdgeInsets.all(8.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ...playlists
                          .take(_playlistsToShow)
                          .map((playlist) => ResultItemCard(
                                title: playlist.name,
                              )),
                    ],
                  ),
                  if (_playlistsToShow < playlists.length)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _playlistsToShow += 8;
                        });
                      },
                      child: const Text('Show more'),
                    ),
                ],
              ],
            ),
          );
        }
      },
    );
  }
}
