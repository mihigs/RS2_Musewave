import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:go_router/go_router.dart';

class PersistentPlayer extends StatefulWidget {
  @override
  _PersistentPlayerState createState() => _PersistentPlayerState();
}

class _PersistentPlayerState extends State<PersistentPlayer> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go(Routes.track);
      },
      child: Container(
        height: 65,
        width: MediaQuery.of(context).size.width,
        color: Colors.blueGrey,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  isPlaying = !isPlaying;
                });
                // Implement your play/pause functionality here
              },
            ),
            SizedBox(width: 10),
            // songInfo != null
            //     ? Image.network(
            //         songInfo.albumArtwork,
            //         height: 50,
            //         width: 50,
            //       )
            //     : Container(
            //         height: 50,
            //         width: 50,
            //         color: Colors.grey,
            //       ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Text(
                //   songInfo != null ? songInfo.title : 'Title',
                //   style: TextStyle(color: Colors.white),
                // ),
                // Text(
                //   songInfo != null ? songInfo.artist : 'Artist',
                //   style: TextStyle(color: Colors.white),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
