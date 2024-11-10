import 'package:flutter/material.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/album_service.dart';
import 'package:frontend/services/notifiers/refresh_notifier.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/widgets/collection/edit_collection_list_item.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditCollectionList extends StatefulWidget {
  final int? contextId;
  final StreamingContextType streamingContextType;
  final bool? isExploreWeekly;

  EditCollectionList({
    this.contextId,
    required this.streamingContextType,
    this.isExploreWeekly = false,
  });

  @override
  State<EditCollectionList> createState() => _EditCollectionListState();
}

class _EditCollectionListState extends State<EditCollectionList> {
  final PlaylistService playlistService = GetIt.I<PlaylistService>();
  final AlbumService albumService = GetIt.I<AlbumService>();

  late Future<Album> albumFuture;
  late Future<Playlist> playlistFuture;

  bool isEditingTitle = false;
  String? newTitle;
  bool? isPublic;

  Playlist? playlist; // Added to store the playlist data

  @override
  void initState() {
    super.initState();
    if (widget.contextId != null) {
      if (widget.streamingContextType == StreamingContextType.ALBUM) {
        albumFuture = albumService.GetAlbumDetails(widget.contextId!);
      } else if (widget.streamingContextType == StreamingContextType.PLAYLIST) {
        if (widget.isExploreWeekly!) {
          playlistFuture = playlistService.GetMyExploreWeeklyPlaylist();
        } else {
          playlistFuture = playlistService.GetPlaylistDetails(widget.contextId!);
        }
      }
    } else {
      if (widget.streamingContextType == StreamingContextType.LIKED) {
        playlistFuture = playlistService.GetMyLikedTracksPlaylist();
      }
    }
  }

  void _toggleEditingTitle() {
    setState(() {
      isEditingTitle = !isEditingTitle;
    });
  }

  void _updatePlaylist(int playlistId) async {
    if (newTitle == null || newTitle!.isEmpty) {
      newTitle = playlist?.name ?? '';
    }
    try {
      await playlistService.UpdatePlaylist(playlistId, newTitle!, isPublic!);
      setState(() {
        isEditingTitle = false;
        // Refresh the playlist data
        playlistFuture = playlistService.GetPlaylistDetails(playlistId);
        GetIt.I<RefreshNotifier>().refresh();
      });
    } catch (e) {
      // Handle error
    }
  }

  void _removeTrackFromPlaylist(int playlistId, int trackId) async {
    try {
      await playlistService.RemoveTrackFromPlaylist(playlistId, trackId);
      setState(() {
        playlistFuture = playlistService.GetPlaylistDetails(playlistId);
      });
    } catch (e) {
      // Handle error
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
      body: FutureBuilder(
        future: playlistFuture,
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
            playlist = snapshot.data as Playlist;
            List<Track> tracks = playlist!.tracks!;
            String title = playlist!.name;
            String? artistName = playlist!.user?.userName;
            int playlistId = playlist!.id;

            // Initialize newTitle and isPublic if not set
            if (newTitle == null) newTitle = title;
            if (isPublic == null) isPublic = playlist!.isPublic ?? false;

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Playlist image placeholder
                    Container(
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
                      child: isEditingTitle
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            TextEditingController(text: newTitle),
                                        onChanged: (value) {
                                          newTitle = value;
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () => _updatePlaylist(playlistId),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  newTitle!,
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: _toggleEditingTitle,
                                ),
                              ],
                            ),
                    ),
                    // Public/Private state display (always visible)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isPublic! ? Icons.public : Icons.lock),
                        SizedBox(width: 8),
                        Text(
                          isPublic!
                              ? AppLocalizations.of(context)!.public
                              : AppLocalizations.of(context)!.private,
                        ),
                        Switch(
                          value: isPublic!,
                          onChanged: (value) {
                            setState(() {
                              isPublic = value;
                            });
                            _updatePlaylist(playlistId);
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: artistName != null
                          ? Text(
                              playlist!.isExploreWeekly ?? false
                                  ? AppLocalizations.of(context)!.made_for_you
                                  : '${AppLocalizations.of(context)!.credits_by}: $artistName',
                              style: TextStyle(fontSize: 16),
                            )
                          : null,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tracks.length,
                        itemBuilder: (context, index) {
                          if (index < tracks.length) {
                            return EditCollectionListItem(
                              StreamingContext(
                                tracks[index],
                                widget.contextId,
                                widget.streamingContextType,
                              ),
                              onRemoveTrack: (trackId) {
                                _removeTrackFromPlaylist(playlistId, trackId);
                              },
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
