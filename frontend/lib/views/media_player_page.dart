import 'package:flutter/material.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/seek_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MediaPlayerPage extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  String trackId;
  String? nextTrackId;
  List<String> previousTrackIds = [];
  String contextId;
  String context;

  MediaPlayerPage(
      {required this.trackId, this.nextTrackId, required this.contextId, required this.context});

  @override
  _MediaPlayerPageState createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  late Track? previousTrackData;
  late Future<Track> trackDataFuture;
  late Future<Track> nextTrackDataFuture;

  bool isPlaying = true;

  @override
    void initState() {
    super.initState();
    initializeTrackData(widget.trackId, widget.contextId, widget.context);
  }


  void updateIsPlaying() {
    setState(() {
      isPlaying = Provider.of<MusicStreamer>(context, listen: false).isPlaying;
    });
  }

  Future<void> initializeTrackData(String currentTrackId, String contextId, String streamingContext) async {
    trackDataFuture = widget.tracksService.getTrack(currentTrackId);
    trackDataFuture.then((response) => {
        Provider.of<MusicStreamer>(context, listen: false).initializeAndPlay(response.signedUrl!)
    });

    if (contextId == "0" || streamingContext == "0"){
      nextTrackDataFuture = widget.tracksService.getNextTrack(currentTrackId);
      nextTrackDataFuture.then((response) {
        widget.nextTrackId = response.id.toString();
      });
    } else {
      switch (streamingContext) {
        case 'album':
          nextTrackDataFuture = widget.tracksService.GetNextAlbumTrack(currentTrackId, contextId);
          break;
        case 'playlist':
          nextTrackDataFuture = widget.tracksService.GetNextPlaylistTrack(currentTrackId, contextId);
          break;
        default:
          nextTrackDataFuture = widget.tracksService.getNextTrack(currentTrackId);
      }
    }
  }

  Future<void> nextTrack() async {
    Provider.of<MusicStreamer>(context, listen: false).stop();
    widget.previousTrackIds.add(widget.trackId);
    widget.trackId = widget.nextTrackId!;
    await initializeTrackData(widget.trackId, widget.contextId, widget.context);
  }

  Future<void> previousTrack() async {
    widget.trackId = widget.previousTrackIds.removeLast();
    await initializeTrackData(widget.trackId, widget.contextId, widget.context);
  }

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
        title: Text('Media Player'),
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    track.title,
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    track.artist.user.userName,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        onPressed: !(widget.previousTrackIds.length > 0) ? null : () async {
                          await previousTrack();
                        },
                      ),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: () async {
                          if (isPlaying) {
                            await model.pause();
                          } else {
                            await model.play();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        onPressed: () async {
                          await nextTrack();
                        },
                      ),
                    ],
                  ),
                  Container(
                    child: SeekBar(),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
