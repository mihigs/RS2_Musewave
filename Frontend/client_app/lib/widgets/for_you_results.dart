import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/HomepageDetailsDto.dart';
import 'package:frontend/models/constants/names.dart';
import 'package:frontend/widgets/result_item_card.dart';
import 'package:go_router/go_router.dart';

class ForYouResults extends StatefulWidget {
  ForYouResults({
    super.key,
    required this.homepageDetails,
  });

  final Future<HomepageDetailsDto> homepageDetails;

  @override
  State<ForYouResults> createState() => _ForYouResultsState();
}

class _ForYouResultsState extends State<ForYouResults> {
  late Future<HomepageDetailsDto> homepageDetails;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: Future.wait([
        widget.homepageDetails,
      ]),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var results = snapshot.data!;
          var exploreWeeklyPlaylistId = results[0].exploreWeeklyPlaylistId;
          var popularJamendoTracks = results[0].popularJamendoTracks;

          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10, left: 10),
                      child: Text(
                        'Made for you',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ResultItemCard(
                        onTap: () => GoRouter.of(context)
                            .push('/playlist/${exploreWeeklyPlaylistId}/true'),
                        title: Names.EXPLORE_WEEKLY_PLAYLIST,
                      ),
                      ResultItemCard(
                        onTap: () => GoRouter.of(context).push('/liked'),
                        title: Names.LIKED_TRACKS_PLAYLIST,
                      ),
                    ],
                  ),
                  if (popularJamendoTracks != null &&
                      popularJamendoTracks.isNotEmpty) ...[
                    const Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10, left: 10),
                      child: Text(
                        'Popular Jamendo Tracks',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: popularJamendoTracks.map<Widget>((track) {
                        return ResultItemCard(
                          onTap: () => GoRouter.of(context)
                              .push('/track/${track.id}/0/3'),
                          title: track.title,
                          subtitle: track.artist?.user?.userName,
                        );
                      }).toList(),
                    ),
                  ]
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
