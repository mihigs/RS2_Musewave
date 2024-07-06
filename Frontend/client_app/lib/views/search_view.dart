import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/SearchQueryResults.dart';
import 'package:frontend/models/search_history_entry.dart';
import 'package:frontend/services/search_service.dart';
import 'package:frontend/widgets/search_bar.dart';
import 'package:frontend/widgets/search_results.dart';
import 'package:get_it/get_it.dart';

class SearchPage extends StatefulWidget {
  final SearchService searchService = GetIt.I<SearchService>();

  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late FocusNode _focusNode;
  bool isSearching = false;
  late Future<SearchQueryResults> _searchResultsFuture;
  late Future<List<SearchHistoryEntry>> _searchHistoryFuture;

  void handleSubmitted(String value) {
    setState(() {
      isSearching = true;
      _searchResultsFuture = widget.searchService.query(value);
    });
  }

  void fetchSearchHistory() {
    setState(() {
      _searchHistoryFuture = widget.searchService.getSearchHistory();
    });
  }

  void handleSearchHistoryEntryTap(String searchTerm) {
    _focusNode.unfocus();
    handleSubmitted(searchTerm);
  }

  void handleRemoveSearchHistoryEntry(int id) async {
    bool success = await widget.searchService.removeSearchHistory(id);
    if (success) {
      fetchSearchHistory();
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    _searchResultsFuture = Future.value(SearchQueryResults(
      tracks: [],
      jamendoTracks: [],
      albums: [],
      artists: [],
      playlists: [],
    ));
    fetchSearchHistory();
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
          margin: EdgeInsets.fromLTRB(10, 35, 10, 10),
          child: SearchBarWidget(
            focusNode: _focusNode,
            key: null,
            onSubmitted: handleSubmitted,
          ),
        ),
        if (!isSearching)
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 5, 5, 5),
              child: FutureBuilder<List<SearchHistoryEntry>>(
                future: _searchHistoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading search history'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No search history'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final entry = snapshot.data![index];
                        return ListTile(
                          title: Text(entry.searchTerm ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => handleRemoveSearchHistoryEntry(entry.id),
                          ),
                          onTap: () => handleSearchHistoryEntryTap(entry.searchTerm ?? ''),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          )
        else
          Expanded(
            child: FutureBuilder<SearchQueryResults>(
              future: _searchResultsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading search results'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No search results'));
                } else {
                  return SearchResults(
                    tracks: snapshot.data!.tracks,
                    jamendoTracks: snapshot.data!.jamendoTracks,
                    albums: snapshot.data!.albums,
                    artists: snapshot.data!.artists,
                    playlists: snapshot.data!.playlists,
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:frontend/models/album.dart';
// import 'package:frontend/models/artist.dart';
// import 'package:frontend/models/playlist.dart';
// import 'package:frontend/models/search_history_entry.dart';
// import 'package:frontend/models/track.dart';
// import 'package:frontend/services/album_service.dart';
// import 'package:frontend/services/artist_service.dart';
// import 'package:frontend/services/playlist_service.dart';
// import 'package:frontend/services/search_service.dart';
// import 'package:frontend/services/tracks_service.dart';
// import 'package:frontend/widgets/search_bar.dart';
// import 'package:frontend/widgets/search_results.dart';
// import 'package:get_it/get_it.dart';

// class SearchPage extends StatefulWidget {
//   final TracksService tracksService = GetIt.I<TracksService>();
//   final AlbumService albumService = GetIt.I<AlbumService>();
//   final ArtistService artistService = GetIt.I<ArtistService>();
//   final PlaylistService playlistService = GetIt.I<PlaylistService>();
//   final SearchService searchService = GetIt.I<SearchService>();

//   SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   late FocusNode _focusNode;
//   bool isSearching = false;
//   late Future<List<Track>> _tracksFuture;
//   late Future<List<Track>> _jamendoTracksFuture;
//   late Future<List<Album>> _albumsFuture;
//   late Future<List<Artist>> _artistsFuture;
//   late Future<List<Playlist>> _playlistsFuture;
//   late Future<List<SearchHistoryEntry>> _searchHistoryFuture;

//   void handleSubmitted(String value) {
//     setState(() {
//       isSearching = true;
//       _tracksFuture = widget.tracksService.getTracksByName(value);
//       _jamendoTracksFuture = widget.tracksService.getJamendoTracksByName(value);
//       _albumsFuture = widget.albumService.getAlbumsByTitle(value);
//       _artistsFuture = widget.artistService.getArtistsByName(value);
//       _playlistsFuture = widget.playlistService.GetPlaylistsByName(value);
//     });
//   }

//   void fetchSearchHistory() {
//     setState(() {
//       _searchHistoryFuture = widget.searchService.getSearchHistory();
//     });
//   }

//   void handleSearchHistoryEntryTap(String searchTerm) {
//     _focusNode.unfocus();
//     handleSubmitted(searchTerm);
//   }

//   void handleRemoveSearchHistoryEntry(int id) async {
//     bool success = await widget.searchService.removeSearchHistory(id);
//     if (success) {
//       fetchSearchHistory();
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     _focusNode.requestFocus();
//     _tracksFuture = Future.value([]);
//     _jamendoTracksFuture = Future.value([]);
//     _albumsFuture = Future.value([]);
//     _artistsFuture = Future.value([]);
//     _playlistsFuture = Future.value([]);
//     fetchSearchHistory();
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Container(
//           margin: EdgeInsets.fromLTRB(10, 35, 10, 10),
//           child: SearchBarWidget(
//             focusNode: _focusNode,
//             key: null,
//             onSubmitted: handleSubmitted,
//           ),
//         ),
//         if (!isSearching)
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(12, 5, 5, 5),
//               child: FutureBuilder<List<SearchHistoryEntry>>(
//                 future: _searchHistoryFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error loading search history'));
//                   } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return Center(child: Text('No search history'));
//                   } else {
//                     return ListView.builder(
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         final entry = snapshot.data![index];
//                         return ListTile(
//                           title: Text(entry.searchTerm ?? ''),
//                           trailing: IconButton(
//                             icon: Icon(Icons.clear),
//                             onPressed: () => handleRemoveSearchHistoryEntry(entry.id),
//                           ),
//                           onTap: () => handleSearchHistoryEntryTap(entry.searchTerm ?? ''),
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           )
//         else
//           Expanded(
//             child: SearchResults(
//               tracksFuture: _tracksFuture,
//               jamendoTracksFuture: _jamendoTracksFuture,
//               albumsFuture: _albumsFuture,
//               artistsFuture: _artistsFuture,
//               playlistsFuture: _playlistsFuture,
//             ),
//           ),
//       ],
//     );
//   }
// }
