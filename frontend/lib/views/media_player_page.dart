import 'package:flutter/material.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/models/user.dart';
// import 'package:flutter_audio_query/flutter_audio_query.dart';

class MediaPlayerPage extends StatefulWidget {
  @override
  _MediaPlayerPageState createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  // Track songInfo;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // songInfo != null
            //     ? Image.network(
            //         songInfo.albumArtwork,
            //         height: 200,
            //         width: 200,
            //       )
            //     : Container(
            //         height: 200,
            //         width: 200,
            //         color: Colors.grey,
            //       ),
            SizedBox(height: 20),
            // Text(
            //   songInfo != null ? songInfo.title : 'Title',
            //   style: TextStyle(fontSize: 24),
            // ),
            // Text(
            //   songInfo != null ? songInfo.artist : 'Artist',
            //   style: TextStyle(fontSize: 18),
            // ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                    // Implement your previous track functionality here
                  },
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                    // Implement your play/pause functionality here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    // Implement your next track functionality here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
