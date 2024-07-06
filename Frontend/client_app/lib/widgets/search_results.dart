import 'package:flutter/material.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/models/constants/result_card_types.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/widgets/cards/result_item_card.dart';
import 'package:go_router/go_router.dart';

class SearchResults extends StatefulWidget {
  final List<Track> tracks;
  final List<Track> jamendoTracks;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;

  const SearchResults({
    super.key,
    required this.tracks,
    required this.jamendoTracks,
    required this.albums,
    required this.artists,
    required this.playlists,
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

  @override
  Widget build(BuildContext context) {
    var tracks = widget.tracks;
    var jamendoTracks = widget.jamendoTracks;
    var albums = widget.albums;
    var artists = widget.artists;
    var playlists = widget.playlists;

    bool noResults = tracks.isEmpty &&
        jamendoTracks.isEmpty &&
        albums.isEmpty &&
        artists.isEmpty &&
        playlists.isEmpty;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (noResults)
              Center(
                child: Text(
                  'No tracks found.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (tracks.isNotEmpty) ...[
              Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Tracks',
                      style: Theme.of(context).textTheme.headlineSmall)),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                childAspectRatio: (4 / 4),
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
                              credits: track.artist?.user?.userName,
                              type: ResultCardType.Track,
                              imageUrl: track.imageUrl,
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
                      style: Theme.of(context).textTheme.headlineSmall)),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                childAspectRatio: (4 / 5),
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
                              credits: track.artist?.user?.userName,
                              type: ResultCardType.Track,
                              imageUrl: track.imageUrl,
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
                      style: Theme.of(context).textTheme.headlineSmall)),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                childAspectRatio: (4 / 4),
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
                              type: ResultCardType.Album,
                              imageUrl: album.coverImageUrl,
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
                      style: Theme.of(context).textTheme.headlineSmall)),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                childAspectRatio: (4 / 4),
                mainAxisSpacing: 5,
                padding: const EdgeInsets.all(8.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  ...artists.take(_artistsToShow).map((artist) {
                    final artistId = artist.jamendoArtistId != null
                        ? artist.jamendoArtistId
                        : artist.id;
                    final hasJamendoId = artist.jamendoArtistId != null;

                    return GestureDetector(
                      onTap: () => GoRouter.of(context)
                          .push('/artist/$artistId/$hasJamendoId'),
                      child: ResultItemCard(
                        title: artist.user!.userName,
                        type: ResultCardType.Artist,
                        imageUrl: artist.artistImageUrl,
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
                      style: Theme.of(context).textTheme.headlineSmall)),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                childAspectRatio: (4 / 4),
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
                              type: ResultCardType.Playlist,
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
}
