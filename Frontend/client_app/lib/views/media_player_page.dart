import 'package:flutter/material.dart';
import 'package:frontend/helpers/helper_functions.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/streaming/music_streamer.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/add_to_playlist.dart';
import 'package:frontend/widgets/seek_bar.dart';
import 'package:frontend/widgets/track_comments.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MediaPlayerPage extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  final String trackId;
  final String contextId;
  final String contextType;

  MediaPlayerPage({
    required this.trackId,
    required this.contextId,
    required this.contextType,
  });

  @override
  MediaPlayerPageState createState() => MediaPlayerPageState();
}

class MediaPlayerPageState extends State<MediaPlayerPage> {
  MusicStreamer? musicStreamer;
  bool trackLoaded = false;
  Track? currentTrack;
  late bool isLiked = false;
  bool isPlaying = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    musicStreamer = Provider.of<MusicStreamer>(context, listen: false);

    updateIsPlaying();
    checkIfTrackAlreadyLoaded();
  }

  void checkIfTrackAlreadyLoaded() {
    setState(() {
      if (musicStreamer == null) return;
      bool trackLoaded = musicStreamer!.trackLoaded;
      var streamingTypeFromURL =
          getStreamingContextTypeFromString(widget.contextType);

      if (!trackLoaded) {
        initializeTrackData(widget.trackId, widget.contextId, widget.contextType);
      } else {
        updateCurrentTrack();
        if (currentTrack?.id.toString() == widget.trackId) {
          updateTrackData();
        } else {
          initializeTrackData(
              widget.trackId, widget.contextId, widget.contextType);
        }
      }
    });
  }

  void updateIsPlaying() {
    setState(() {
      if (musicStreamer != null) {
        isPlaying = musicStreamer!.isPlaying;
      }
    });
  }

  void updateIsLiked() {
    setState(() {
      if (musicStreamer != null) {
        isLiked = musicStreamer!.isLiked;
      }
    });
  }

  void updateCurrentTrack() {
    setState(() {
      var currentTrackFromProvider = musicStreamer?.currentTrack;
      if (currentTrackFromProvider?.id != currentTrack?.id &&
          currentTrackFromProvider != null) {
        currentTrack = currentTrackFromProvider;
        isLiked = currentTrack!.isLiked ?? false;
      }
    });
  }

  void updateTrackData() {
    setState(() {
      currentTrack = musicStreamer!.currentTrack!;
      if (currentTrack != null) {
        isLiked = currentTrack!.isLiked ?? false;
      }
    });
  }

  Future<void> initializeTrackData(String currentTrackId, String contextId,
      String streamingContextType) async {
    Track currentTrackResult =
        await widget.tracksService.getTrack(int.parse(currentTrackId));
    setState(() {
      currentTrack = currentTrackResult;
    });
    if (currentTrack != null) {
      if (currentTrack!.isLiked == null) {
        isLiked = false;
      } else {
        isLiked = currentTrack!.isLiked!;
      }

      if (musicStreamer != null) {
        mounted
            ? musicStreamer!.startTrack(StreamingContext(
                currentTrack!,
                int.parse(contextId),
                getStreamingContextTypeFromString(streamingContextType)))
            : null;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (musicStreamer != null) {
      musicStreamer!.addListener(updateIsPlaying);
      musicStreamer!.addListener(updateIsLiked);
      musicStreamer!.addListener(updateCurrentTrack);
    }
  }

  @override
  void dispose() {
    musicStreamer!.removeListener(updateIsPlaying);
    musicStreamer!.removeListener(updateIsLiked);
    musicStreamer!.removeListener(updateCurrentTrack);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MusicStreamer model = musicStreamer!;
    final isJamendoArtist = model.currentTrack?.jamendoId != null;
    final artistId = isJamendoArtist
        ? model.currentTrack?.artist?.jamendoArtistId
        : model.currentTrack?.artist?.id;

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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.comment, size: 31),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return FractionallySizedBox(heightFactor: 0.9, child: TrackCommentsModal(trackId: widget.trackId));
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.playlist_add, size: 32),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return AddToPlaylistModal(trackId: widget.trackId);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(isLiked ? Icons.star : Icons.star_border, size: 32),
            onPressed: () async {
              if (currentTrack != null) {
                widget.tracksService
                    .toggleLikeTrack(currentTrack!.id)
                    .then((response) => {
                          if (response) {
                            model.toggleIsLiked(),
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 1), content: Text(isLiked ? AppLocalizations.of(context)!.track_added_to_favorites : AppLocalizations.of(context)!.track_removed_from_favorites),))
                          }
                        });
              }
            },
          )
        ],
      ),
      body: currentTrack == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Track cover art
                  model.currentTrack!.imageUrl != null
                      ? Container(
                          height: 275,
                          width: 275,
                          child: Image.network(
                            model.currentTrack!.imageUrl!,
                            fit: BoxFit
                                .cover, // Adjust the images fit as needed
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null)
                                return child; // Image has finished loading
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        )
                      : Container(
                          height: 275,
                          width: 275,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.deepPurple, Colors.purpleAccent],
                            ),
                          ),
                        ),
                  // Displaying current track title
                  Container(
                    width: double.infinity - 10,
                    height: MediaQuery.of(context).size.height * 0.09,
                    child: Text(
                      model.currentTrackTitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Displaying current track artist name
                  GestureDetector(
                    onTap: () => {
                      GoRouter.of(context).push('/artist/$artistId/${isJamendoArtist ? "true" : "false"}',
                      )
                    },
                    child: Container(
                      width: double.infinity - 15,
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Text(
                        currentTrack!.artist!.user!.userName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.skip_previous, size: 58),
                        onPressed: () async {
                          await model.playPreviousTrack();
                        },
                      ),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 58),
                        onPressed: () {
                          if (isPlaying) {
                            model.pause();
                          } else {
                            model.play();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next, size: 58),
                        onPressed: () async {
                          await model.playNextTrack();
                        },
                      ),
                    ],
                  ),
                  Container(
                    child: SeekBar(),
                  ),
                ],
              ),
            ),
    );
  }
}
