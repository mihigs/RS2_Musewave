import 'package:flutter/material.dart';
import 'package:frontend/helpers/helperFunctions.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PersistentPlayer extends StatefulWidget {
  @override
  _PersistentPlayerState createState() => _PersistentPlayerState();
}

class _PersistentPlayerState extends State<PersistentPlayer> {
  bool isPlaying = false;
  int? currentTrackId;

  void updateCurrentTrack() {
    setState(() {
      currentTrackId =
          Provider.of<MusicStreamer>(context, listen: false).currentTrack?.id;
    });
  }

  void updateIsPlaying() {
    setState(() {
      isPlaying = Provider.of<MusicStreamer>(context, listen: false).isPlaying;
    });
  }

  @override
    void initState() {
    super.initState();

    updateIsPlaying();
    updateCurrentTrack();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MusicStreamer>(context);

    return GestureDetector(
      onTap: () {
        if(model.currentTrack != null && model.currentStreamingContext != null){
          var trackId = model.currentTrack!.id;
          var contextId = model.currentStreamingContext!.contextId;
          var streamingContextType = getStringFromStreamingContextType(model.currentStreamingContext!.type);
          GoRouter.of(context).go('/track/$trackId/$contextId/$streamingContextType/false');
        }
      },
      child: Container(
        height: 65,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        width: MediaQuery.of(context).size.width,
        color: Colors.blueGrey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey,
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.currentTrackTitle ?? 'No track playing',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      model.currentTrackArtist ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
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
          ],
        ),
      ),
    );
  }
}
