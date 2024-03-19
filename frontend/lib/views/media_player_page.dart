import 'package:flutter/material.dart';
import 'package:frontend/helpers/helperFunctions.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/seek_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class MediaPlayerPage extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  String trackId;
  // String? nextTrackId;
  // List<String> previousTrackIds = [];
  String contextId;
  String contextType;
  String autoStart;

  MediaPlayerPage(
      {required this.trackId,
      required this.contextId,
      required this.contextType,
      required this.autoStart});

  @override
  _MediaPlayerPageState createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  late bool trackLoaded;
  // late Track? previousTrackData;
  late Track currentTrack;
  // late Future<Track> nextTrackDataFuture;
  late bool isLiked = false;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    updateIsPlaying();
    checkIfTrackAlreadyLoaded();

    initializeTrackData(
        widget.trackId, widget.contextId, widget.contextType, widget.autoStart);
    // Provider.of<MusicStreamer>(context, listen: false)
    //     .getPlayerStateStream()
    //     .listen((playerState) {
    //   if (playerState.processingState == ProcessingState.completed) {
    //     nextTrack();
    //   }
    // });
  }

  void checkIfTrackAlreadyLoaded() {
    setState(() {
      trackLoaded =
          Provider.of<MusicStreamer>(context, listen: false).trackLoaded;
    });
  }

  void updateIsPlaying() {
    setState(() {
      isPlaying = Provider.of<MusicStreamer>(context, listen: false).isPlaying;
    });
  }

  void updateCurrentTrack() {
    setState(() {
      currentTrack =
          Provider.of<MusicStreamer>(context, listen: false).currentTrack!;
    });
  }

  Future<void> initializeTrackData(String currentTrackId, String contextId,
      String streamingContextType, String autoStart) async {
    currentTrack =
        await widget.tracksService.getTrack(int.parse(currentTrackId));
    if (currentTrack.isLiked == null) {
      isLiked = false;
    } else {
      isLiked = currentTrack.isLiked!;
    }
    ;
    if (autoStart == "true") {
      Provider.of<MusicStreamer>(context, listen: false).startTrack(
          StreamingContext(currentTrack, int.parse(contextId),
              getStreamingContextTypeFromString(streamingContextType)));
    } else {
      Provider.of<MusicStreamer>(context, listen: false).startTrack(
          StreamingContext(currentTrack, int.parse(contextId),
              getStreamingContextTypeFromString(streamingContextType)));
    }

    // if (contextId == "0" || streamingContext == "0") {
    //   nextTrackDataFuture = widget.tracksService.getNextTrack(currentTrackId);
    //   nextTrackDataFuture.then((currentTrack) {
    //     widget.nextTrackId = currentTrack.id.toString();
    //   });
    // } else {
    //   switch (streamingContext) {
    //     case 'album':
    //       nextTrackDataFuture =
    //           widget.tracksService.GetNextAlbumTrack(currentTrackId, contextId);
    //       break;
    //     case 'playlist':
    //       nextTrackDataFuture = widget.tracksService
    //           .GetNextPlaylistTrack(currentTrackId, contextId);
    //       break;
    //     default:
    //       nextTrackDataFuture =
    //           widget.tracksService.getNextTrack(currentTrackId);
    //   }
    // }
  }

  // Future<void> nextTrack() async {
  //   await Provider.of<MusicStreamer>(context, listen: false).stop();
  //   widget.previousTrackIds.add(widget.trackId);
  //   widget.trackId = widget.nextTrackId!;
  //   widget.autoStart = "true";
  //   await initializeTrackData(widget.trackId, widget.contextId, widget.context);
  // }

  // Future<void> previousTrack() async {
  //   widget.trackId = widget.previousTrackIds.removeLast();
  //   widget.autoStart = "true";
  //   await initializeTrackData(widget.trackId, widget.contextId, widget.context);
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to the MusicStreamer and update isPlaying when it changes
    Provider.of<MusicStreamer>(context, listen: false)
        .addListener(updateIsPlaying);

    Provider.of<MusicStreamer>(context, listen: false)
        .addListener(updateCurrentTrack);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed to avoid memory leaks
    Provider.of<MusicStreamer>(context, listen: false)
        .removeListener(updateIsPlaying);
    Provider.of<MusicStreamer>(context, listen: false)
        .removeListener(updateCurrentTrack);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MusicStreamer model = Provider.of<MusicStreamer>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back
            GoRouter.of(context).go('/home');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(isLiked ? Icons.star : Icons.star_border, size: 32),
            onPressed: () async {
              // Toggle like status of the current track, this logic may need to be adjusted
              // based on your application's functionality
              isLiked = !isLiked;
              setState(() {});
            },
          ),
        ],
      ),
      body: currentTrack == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Placeholder for track cover art
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Displaying current track title
                  Text(
                    model.currentTrackTitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // Displaying current track artist name
                  Text(
                    currentTrack!.artist!.user!.userName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
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
                  // Your SeekBar widget
                  Expanded(
                    child: SeekBar(),
                  ),
                ],
              ),
            ),
    );
  }
}
