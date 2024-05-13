import 'package:flutter/material.dart';
import 'package:frontend/helpers/helper_functions.dart';
import 'package:frontend/streaming/music_streamer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PersistentPlayer extends StatefulWidget {
  @override
  _PersistentPlayerState createState() => _PersistentPlayerState();
}

class _PersistentPlayerState extends State<PersistentPlayer> {
  MusicStreamer? musicStreamer;
  bool isPlaying = false;
  int? currentTrackId;

  void updateCurrentTrack() {
    setState(() {
      if(musicStreamer != null){
        currentTrackId = musicStreamer!.currentTrack?.id;
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

  @override
    void initState() {
    super.initState();

    musicStreamer = Provider.of<MusicStreamer>(context, listen: false);

    updateIsPlaying();
    updateCurrentTrack();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (musicStreamer != null) {
      musicStreamer!.addListener(updateIsPlaying);
      musicStreamer!.addListener(updateCurrentTrack);
    }
  }

  @override
  void dispose() {
    musicStreamer?.removeListener(updateIsPlaying);
    musicStreamer?.removeListener(updateCurrentTrack);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = musicStreamer!;

    return GestureDetector(
      onTap: () {
        if(model.currentTrack != null && model.currentStreamingContext != null){
          var trackId = model.currentTrack!.id;
          var contextId = model.currentStreamingContext!.contextId;
          var streamingContextType = getStringFromStreamingContextType(model.currentStreamingContext!.type);
          GoRouter.of(context).push('/track/$trackId/$contextId/$streamingContextType');
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          overflow: TextOverflow.clip,
                          model.currentTrackTitle ?? 'No track playing',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        child: Text(
                          overflow: TextOverflow.clip,
                          model.currentTrackArtist ?? '',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
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
