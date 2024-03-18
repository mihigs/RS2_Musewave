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
      // this.nextTrackId,
      required this.contextId,
      required this.contextType,
      required this.autoStart});

  @override
  _MediaPlayerPageState createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  late bool trackLoaded;
  // late Track? previousTrackData;
  late Future<Track> trackDataFuture;
  // late Future<Track> nextTrackDataFuture;
  late bool isLiked = false;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    updateIsPlaying();
    checkIfTrackAlreadyLoaded();


    initializeTrackData(widget.trackId, widget.contextId, widget.contextType);
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

  Future<void> initializeTrackData(
      String currentTrackId, String contextId, String streamingContextType) async {
      trackDataFuture = widget.tracksService.getTrack(int.parse(currentTrackId));
      trackDataFuture.then((response) => {
          if (response.isLiked == null)
            {
              isLiked = false,
            }
          else
            {
              isLiked = response.isLiked!,
            },
          if (!trackLoaded && (widget.autoStart == "true"))
            {
              Provider.of<MusicStreamer>(context, listen: false)
                  .startTrack(StreamingContext(
                      response,
                      int.parse(contextId),
                      getStreamingContextTypeFromString(streamingContextType)))            }
          else if (!trackLoaded && (widget.autoStart == "false"))
            {
              Provider.of<MusicStreamer>(context, listen: false)
                  .initializeTrack(StreamingContext(
                      response,
                      int.parse(contextId),
                      getStreamingContextTypeFromString(streamingContextType)))
            }
        });

    // if (contextId == "0" || streamingContext == "0") {
    //   nextTrackDataFuture = widget.tracksService.getNextTrack(currentTrackId);
    //   nextTrackDataFuture.then((response) {
    //     widget.nextTrackId = response.id.toString();
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
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed to avoid memory leaks
    Provider.of<MusicStreamer>(context, listen: false)
        .removeListener(updateIsPlaying);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MusicStreamer>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // close this modal
            GoRouter.of(context).go('/home');
          },
        ),
        actions: <Widget>[
          Container(
            // padding: EdgeInsets.all(0),
            // width: 30,
            // height: 30,
            child: IconButton(
              icon: Icon(isLiked ? Icons.star : Icons.star_border, size: 32),
              onPressed: () async {
                var snackBar;
                if (isLiked) {
                  var unlikedSuccessfuly = await widget.tracksService
                      .toggleLikeTrack(int.parse(widget.trackId));
                  if (unlikedSuccessfuly) {
                    setState(() {
                      isLiked = false;
                    });
                  }
                } else {
                  var likedSuccessfuly = await widget.tracksService
                      .toggleLikeTrack(int.parse(widget.trackId));
                  if (likedSuccessfuly) {
                    setState(() {
                      isLiked = true;
                    });
                    snackBar = const SnackBar(
                      content: Text('Added to favorites!'),
                      duration: Duration(seconds: 1),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ),
        ],
        // title: Text('Media Player'),
      ),
      body: Center(
        child: FutureBuilder<Track>(
          future: trackDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              Track track = snapshot.data!;
              return Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // Track cover art placeholder with purple gradient background
                      height: 200,
                      width: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.purple, Colors.deepPurple],
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      child: Text(
                        track.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      child: Text(
                        track.artist!.user!.userName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          child: IconButton(
                            icon: Icon(Icons.skip_previous, size: 58),
                            onPressed: !(model.journeyHistoryIds.length > 0)
                                ? null
                                : () async {
                                    await model.playPreviousTrack();
                                  },
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          child: IconButton(
                            icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 58),
                            onPressed: () async {
                              if (isPlaying) {
                                await model.pause();
                              } else {
                                await model.play();
                              }
                            },
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          child: IconButton(
                            icon: Icon(Icons.skip_next, size: 58),
                            onPressed: () async {
                              await model.playNextTrack();
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SeekBar(),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
