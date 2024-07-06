import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/HomepageDetailsDto.dart';
import 'package:frontend/models/constants/names.dart';
import 'package:frontend/models/constants/result_card_types.dart';
import 'package:frontend/widgets/cards/result_item_card.dart';
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
                    padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 10),
                    child: Text(
                      'Made for you',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                      mainAxisExtent: 130.0, // Height of each cell
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 2, // Number of items in the grid
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ResultItemCard(
                          onTap: () => GoRouter.of(context)
                              .push('/playlist/${exploreWeeklyPlaylistId}/true'),
                          title: Names.EXPLORE_WEEKLY_PLAYLIST,
                          type: ResultCardType.Playlist,
                        );
                      } else {
                        return ResultItemCard(
                          onTap: () => GoRouter.of(context).push('/liked'),
                          title: Names.LIKED_TRACKS_PLAYLIST,
                          type: ResultCardType.Playlist,
                        );
                      }
                    },
                  ),
                  if (popularJamendoTracks != null &&
                      popularJamendoTracks.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 10),
                      child: Text(
                        'Popular Jamendo Tracks',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        mainAxisExtent: 160.0, // Height of each cell
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: popularJamendoTracks.length,
                      itemBuilder: (context, index) {
                        var track = popularJamendoTracks[index];
                        return ResultItemCard(
                          onTap: () => GoRouter.of(context)
                              .push('/track/${track.id}/0/3'),
                          title: track.title,
                          credits: track.artist?.user?.userName,
                          type: ResultCardType.Track,
                          imageUrl: track.imageUrl,
                        );
                      },
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
