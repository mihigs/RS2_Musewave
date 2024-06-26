import 'package:flutter/material.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/streaming/music_streamer.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/widgets/result_item_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchResults extends StatefulWidget {
  final Future<List<Track>> tracksFuture;
  final Future<List<Track>> jamendoTracksFuture;
  final Future<List<Album>> albumsFuture;
  final Future<List<Artist>> artistsFuture;
  final Future<List<Playlist>> playlistsFuture;

  const SearchResults({
    super.key,
    required this.tracksFuture,
    required this.jamendoTracksFuture,
    required this.albumsFuture,
    required this.artistsFuture,
    required this.playlistsFuture,
  });

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  int _tracksToShow = 3;
  int _jamendoTracksToShow = 6;
  int _albumsToShow = 3;
  int _artistsToShow = 3;
  int _playlistsToShow = 3;

  final List<Track> _errorTrackList = [];
  final List<Track> _errorJamendoTrackList = [];
  final List<Album> _errorAlbumList = [];
  final List<Artist> _errorArtistList = [];
  final List<Playlist> _errorPlaylistList = [];

  @override
  Widget build(BuildContext context) {
    final MusicStreamer model =
        Provider.of<MusicStreamer>(context, listen: false);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        widget.tracksFuture.catchError((_) {
          print("Error fetching tracks");
          return _errorTrackList;
        }),
        widget.jamendoTracksFuture.catchError((_) {
          print("Error fetching jamendo tracks");
          return _errorJamendoTrackList;
        }),
        widget.albumsFuture.catchError((_) {
          print("Error fetching albums");
          return _errorAlbumList;
        }),
        widget.artistsFuture.catchError((_) {
          print("Error fetching artists");
          return _errorArtistList;
        }),
        widget.playlistsFuture.catchError((_) {
          print("Error fetching playlists");
          return _errorPlaylistList;
        })
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          print("Snapshot data: ${snapshot.data}");
          var results = snapshot.data!;
          var tracks =
              results[0] != _errorTrackList ? results[0] as List<Track> : [];
          var jamendoTracks = results[1] != _errorJamendoTrackList
              ? results[1] as List<Track>
              : [];
          var albums =
              results[2] != _errorAlbumList ? results[2] as List<Album> : [];
          var artists =
              results[3] != _errorArtistList ? results[3] as List<Artist> : [];
          var playlists = results[4] != _errorPlaylistList
              ? results[4] as List<Playlist>
              : [];

          print("Tracks: $tracks");
          print("Jamendo Tracks: $jamendoTracks");
          print("Albums: $albums");
          print("Artists: $artists");
          print("Playlists: $playlists");

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (tracks.isNotEmpty) ...[
                    Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('Tracks',
                            style: Theme.of(context).textTheme.headlineMedium)),
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
                                  onTap: () => GoRouter.of(context)
                                      .push('/track/${track.id}/0/0'),
                                  child: ResultItemCard(
                                    title: track.title,
                                    subtitle: track.artist?.user?.userName,
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
                  if (jamendoTracks.isNotEmpty) ...[
                    Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('Jamendo Tracks',
                            style: Theme.of(context).textTheme.headlineMedium)),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      padding: const EdgeInsets.all(8.0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        ...jamendoTracks
                            .take(_jamendoTracksToShow)
                            .map((track) => GestureDetector(
                                  onTap: () => {
                                    GoRouter.of(context)
                                        .push('/track/${track.id}/0/3'),
                                  },
                                  child: ResultItemCard(
                                    title: track.title,
                                    subtitle: track.artist?.user?.userName,
                                  ),
                                )),
                      ],
                    ),
                    if (_jamendoTracksToShow < jamendoTracks.length)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _jamendoTracksToShow += 8;
                          });
                        },
                        child: Text('Show more'),
                      ),
                  ],
                  if (albums.isNotEmpty) ...[
                    Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('Albums',
                            style: Theme.of(context).textTheme.headlineMedium)),
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
                            .map((album) => GestureDetector(
                                  onTap: () => GoRouter.of(context)
                                      .push('/album/${album.id}'),
                                  child: ResultItemCard(
                                    title: album.title,
                                    subtitle: album.artist?.user?.userName,
                                  ),
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
                            style: Theme.of(context).textTheme.headlineMedium)),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      padding: const EdgeInsets.all(8.0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        ...artists.take(_artistsToShow).map((artist) {
                          final artistId = artist.jamendoArtistId != null &&
                                  artist.jamendoArtistId.isNotEmpty
                              ? artist.jamendoArtistId
                              : artist.id;
                          final hasJamendoId = artist.jamendoArtistId != null &&
                              artist.jamendoArtistId.isNotEmpty;

                          return GestureDetector(
                            onTap: () => GoRouter.of(context)
                                .push('/artist/$artistId/$hasJamendoId'),
                            child: ResultItemCard(
                              title: artist.user!.userName,
                            ),
                          );
                        }),
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
                            style: Theme.of(context).textTheme.headlineMedium)),
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
                            .map((playlist) => GestureDetector(
                                  onTap: () => GoRouter.of(context)
                                      .push('/playlist/${playlist.id}/false'),
                                  child: ResultItemCard(
                                    title: playlist.name,
                                  ),
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
            ),
          );
        }
      },
    );
  }
}
