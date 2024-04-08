import 'package:flutter/material.dart';
import 'package:frontend/helpers/helper_functions.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/album_service.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/widgets/collection/collection_list_item.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Make sure you have provider package imported

class CollectionList extends StatefulWidget {
  int? contextId;
  StreamingContextType streamingContextType;
  bool? isExploreWeekly = false;

  CollectionList({
    // required this.title,
    // required this.artistName,
    // required this.tracks,
    this.contextId,
    required this.streamingContextType,
    this.isExploreWeekly = false
  });

  @override
  State<CollectionList> createState() => _CollectionListState();
}

late Future<Album> albumFuture;
late Future<Playlist> playlistFuture;

class _CollectionListState extends State<CollectionList> {
  final PlaylistService playlistService = GetIt.I<PlaylistService>();
  final AlbumService albumService = GetIt.I<AlbumService>();

  @override
  void initState() {
    super.initState();
    if(widget.contextId != null){
      if (widget.streamingContextType == StreamingContextType.ALBUM) {
        albumFuture = albumService.GetAlbumDetails(widget.contextId!);
      } else if (widget.streamingContextType == StreamingContextType.PLAYLIST) {
        if(widget.isExploreWeekly!){
          playlistFuture = playlistService.GetExploreWeeklyPlaylist();
        }else{
          playlistFuture = playlistService.GetPlaylistDetailsAsync(widget.contextId!);
        }
      } 
    }else{
      if (widget.streamingContextType == StreamingContextType.LIKED){
        playlistFuture = playlistService.GetLikedTracksPlaylist();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
      ),
      body: Expanded(
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: widget.streamingContextType == StreamingContextType.ALBUM ? albumFuture : playlistFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.only(top: 250),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                // Extract data from snapshot
                List<Track> tracks;
                String title;
                String? artistName;
                Album? album;
                Playlist? playlist;
        
                if (widget.streamingContextType == StreamingContextType.ALBUM) {
                  album = snapshot.data as Album;
                  tracks = album.tracks;
                  title = album.title;
                  artistName = album.artist!.user!.userName;
                } else {
                  playlist = snapshot.data as Playlist;
                  tracks = playlist.tracks!;
                  title = playlist.name;
                  artistName = playlist.user?.userName;
                }
        
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        // Track cover art placeholder with purple gradient background
                        height: 150,
                        width: 150,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: artistName != null ? Text(
                          playlist?.isExploreWeekly ?? false ? 'Made for you' : 'by: $artistName',
                          style: TextStyle(fontSize: 16),
                        ) : null,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: tracks.length,
                          itemBuilder: (context, index) {
                            if (index < tracks.length) {
                              return CollectionListItem(
                                StreamingContext(
                                  tracks[index],
                                  widget.contextId,
                                  widget.streamingContextType,
                                ),
                              );
                            } else {
                              // Handle null or out-of-bounds index
                              return SizedBox(); // Or return an empty widget, depending on your UI design
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}