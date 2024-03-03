import 'package:flutter/material.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/widgets/result_item_card.dart';

class ForYouResults extends StatefulWidget {
  const ForYouResults({
    super.key,
    required this.likedTracksFuture,
  });

  final Future<List<Track>> likedTracksFuture;

  @override
  State<ForYouResults> createState() => _ForYouResultsState();
}

class _ForYouResultsState extends State<ForYouResults> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Track>>(
      future: widget.likedTracksFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Track>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Track> likedTracks = snapshot.data!;
          return GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                ...likedTracks.map((track) {
                  return ResultItemCard(
                      title: track.title,
                      subtitle: track.artist.user.userName,
                  );
                }),
              ],
          );
        }
      },
    );
  }
}
