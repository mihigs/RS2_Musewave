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
  MusicStreamer? musicStreamer;
  bool trackLoaded = false; //LateError (LateInitializationError: Field 'trackLoaded' has not been initialized.) TODO
  Track? currentTrack;
  late bool isLiked = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    musicStreamer = Provider.of<MusicStreamer>(context, listen: false);

    updateIsPlaying();
    checkIfTrackAlreadyLoaded();
  }

  void checkIfTrackAlreadyLoaded() {
    setState(() {
      if(musicStreamer != null){
        trackLoaded = musicStreamer!.trackLoaded;

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
    });
  }

  void updateIsPlaying() {
    setState(() {
      if(musicStreamer != null){
        isPlaying = musicStreamer!.isPlaying;
      }
    });
  }

  void updateIsLiked() {
    setState(() {
      if(musicStreamer != null){
        isLiked = musicStreamer!.isLiked;
      }
    });
  }

  void updateCurrentTrack() {
    setState(() { 
      var currentTrackFromProvider = musicStreamer?.currentTrack;
      if(currentTrackFromProvider?.id != currentTrack?.id && currentTrackFromProvider != null){
        currentTrack = currentTrackFromProvider;
        isLiked = currentTrack!.isLiked ?? false;
      }
    });
  }

  void updateTrackData(){
    setState(() {
      currentTrack = musicStreamer!.currentTrack!;
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

      if(musicStreamer != null){
        mounted ? musicStreamer!.startTrack(
                StreamingContext(currentTrack!, int.parse(contextId),
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
                    decoration: const BoxDecoration(
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
