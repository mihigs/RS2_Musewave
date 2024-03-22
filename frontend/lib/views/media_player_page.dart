import 'package:flutter/material.dart';
import 'package:frontend/helpers/helperFunctions.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/seek_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MediaPlayerPage extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  final String trackId;
  final String contextId;
  final String contextType;
  final String autoStart;

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
  Track? currentTrack;
  late bool isLiked = false;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    updateIsPlaying();
    checkIfTrackAlreadyLoaded();

    initializeTrackData(
        widget.trackId, widget.contextId, widget.contextType, widget.autoStart);
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
    Track currentTrackResult = await widget.tracksService.getTrack(int.parse(currentTrackId));
    setState(() {
      currentTrack = currentTrackResult;
    });
    if(currentTrack != null){
      if (currentTrack!.isLiked == null) {
        isLiked = false;
      } else {
        isLiked = currentTrack!.isLiked!;
      }
      if (autoStart == "true") {
        mounted ? Provider.of<MusicStreamer>(context, listen: false).startTrack(
            StreamingContext(currentTrack!, int.parse(contextId),
                getStreamingContextTypeFromString(streamingContextType))) : null;
      } else {
        mounted ? Provider.of<MusicStreamer>(context, listen: false).startTrack(
            StreamingContext(currentTrack!, int.parse(contextId),
                getStreamingContextTypeFromString(streamingContextType))) : null;
      }
    }
  }

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
