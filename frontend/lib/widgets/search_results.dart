import 'package:flutter/material.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/widgets/result_item_card.dart';

class SearchResults extends StatelessWidget {
  final Future<List<Track>> tracksFuture;
  final Future<List<Album>> albumsFuture;

  const SearchResults({
    Key? key,
    required this.tracksFuture,
    required this.albumsFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([tracksFuture, albumsFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var results = snapshot.data!;
          var tracks = results[0] as List<Track>;
          var albums = results[1] as List<Album>;

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (tracks.isNotEmpty) ...[
                  Text('Tracks', style: Theme.of(context).textTheme.headline4),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    padding: const EdgeInsets.all(8.0),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ...tracks.map((track) => ResultItemCard(
                            title: track.title,
                            subtitle: track.artist.user.userName,
                          )),
                    ],
                  ),
                ],
                if (albums.isNotEmpty) ...[
                  Text('Albums', style: Theme.of(context).textTheme.headline4),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    padding: const EdgeInsets.all(8.0),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ...albums.map((album) => ResultItemCard(
                            title: album.title,
                            subtitle: album.artist.user.userName,
                          )),
                    ],
                  ),
                ],
              ],
            ),
          );
        }
      },
    );
  }
}
