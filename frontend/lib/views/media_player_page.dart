import 'package:flutter/material.dart';
import 'package:frontend/helpers/helperFunctions.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/router.dart';
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

  MediaPlayerPage(
    {
      required this.trackId,
      required this.contextId,
      required this.contextType,
    }
  );

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

    if (!trackLoaded) {
      initializeTrackData(widget.trackId, widget.contextId, widget.contextType);
    } else {
      updateCurrentTrack();
      if (currentTrack?.id.toString() != widget.trackId) {
        initializeTrackData(widget.trackId, widget.contextId, widget.contextType);
      } else {
        updateTrackData();
      }
    }

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

  void updateIsLiked() {
    setState(() {
      isLiked = Provider.of<MusicStreamer>(context, listen: false).isLiked;
    });
  }

  void updateCurrentTrack() {
    setState(() {
      var currentTrackFromProvider = Provider.of<MusicStreamer>(context, listen: false).currentTrack!;
      if(currentTrackFromProvider.id != currentTrack?.id){
        currentTrack = currentTrackFromProvider;
        isLiked = currentTrack!.isLiked ?? false;
      }
    });
  }

  void updateTrackData(){
    setState(() {
      currentTrack = Provider.of<MusicStreamer>(context, listen: false).currentTrack!;
      if(currentTrack != null){
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

      mounted
          ? Provider.of<MusicStreamer>(context, listen: false).startTrack(
              StreamingContext(currentTrack!, int.parse(contextId),
                  getStreamingContextTypeFromString(streamingContextType)))
          : null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to the MusicStreamer and update isPlaying when it changes
    Provider.of<MusicStreamer>(context, listen: false)
        .addListener(updateIsPlaying);
    Provider.of<MusicStreamer>(context, listen: false)
        .addListener(updateIsLiked);
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
    Provider.of<MusicStreamer>(context, listen: false)
        .addListener(updateIsLiked);
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
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(isLiked ? Icons.star : Icons.star_border, size: 32),
              onPressed: () async {
                if(currentTrack != null){
                  widget.tracksService.toggleLikeTrack(currentTrack!.id).then((response) => {
                    if (response) {
                      model.toggleIsLiked()
                    }
                  });
                }
              },
          ),
        ],
      ),
      body: currentTrack == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // space-around
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Placeholder for track cover art
                  Container(
                    height: 275,
                    width: 275,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Displaying current track title
                  Text(
                    model.currentTrackTitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  // Displaying current track artist name
                  Text(
                    currentTrack!.artist!.user!.userName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 40),
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
                  SizedBox(height: 20),
                  Expanded(
                    child: SeekBar(),
                  ),
                ],
              ),
            ),
    );
  }
}
