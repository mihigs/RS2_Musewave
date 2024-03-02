import 'package:flutter/material.dart';
import 'package:frontend/models/track.dart';

class ForYouResults extends StatelessWidget {
  const ForYouResults({
    super.key,
    required this.likedTracksFuture,
  });

  final Future<List<Track>> likedTracksFuture;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Track>>(
      future: likedTracksFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<Track>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show a loading spinner while waiting
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error message if something went wrong
            } else {
              List<Track> likedTracks = snapshot.data!;
              return ListView.builder(
                itemCount: likedTracks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(likedTracks[index].title),
                    ),
                  );
                },
              );
            }
      },
    ));
  }
}
