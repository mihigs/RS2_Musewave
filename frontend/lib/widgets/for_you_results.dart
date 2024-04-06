import 'package:flutter/material.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/widgets/result_item_card.dart';
import 'package:go_router/go_router.dart';

class ForYouResults extends StatefulWidget {
  const ForYouResults({
    super.key,
    required this.exploreWeeklyPlaylist,
  });

  final Future<Playlist> exploreWeeklyPlaylist;

  @override
  State<ForYouResults> createState() => _ForYouResultsState();
}

class _ForYouResultsState extends State<ForYouResults> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: Future.wait([
        widget.exploreWeeklyPlaylist,
      ]),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var results = snapshot.data!;
          var exploreWeeklyPlaylist = results[0] as Playlist;

          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: GridView.count(
                crossAxisCount: 3,
                children: <Widget>[
                  ResultItemCard(
                      onTap:() => GoRouter.of(context).push('/playlist/${exploreWeeklyPlaylist.id}'),
                      title: exploreWeeklyPlaylist.name,
                  ),
                  // ...likedTracks.map((track) {
                  //   return ResultItemCard(
                  //       onTap:() => GoRouter.of(context).push('/track/${track.id}/0/0'),
                  //       title: track.title,
                  //       subtitle: track.artist?.user?.userName,
                  //   );
                  // }),
                ],
            ),
          );
        }
      },
    );
  }
}
