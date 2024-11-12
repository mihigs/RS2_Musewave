import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/HomepageDetailsDto.dart';
import 'package:frontend/models/constants/result_card_types.dart';
import 'package:frontend/widgets/cards/result_item_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            child: CustomScrollView(
              slivers: [
                // Header for "Made for You"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 10, left: 10),
                    child: Text(
                      AppLocalizations.of(context)!.made_for_you,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                // Grid for "Made for You" items
                SliverPadding(
                  padding: const EdgeInsets.all(5.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0, // Maximum width of each grid item
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                      childAspectRatio: 0.75, // Height of each grid item
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index == 0) {
                          return ResultItemCard(
                            onTap: () => GoRouter.of(context)
                                .push('/playlist/${exploreWeeklyPlaylistId}/true'),
                            title: AppLocalizations.of(context)!.explore_weekly,
                            type: ResultCardType.Playlist,
                          );
                        } else {
                          return ResultItemCard(
                            onTap: () => GoRouter.of(context).push('/liked'),
                            title: AppLocalizations.of(context)!.liked_tracks,
                            type: ResultCardType.Playlist,
                          );
                        }
                      },
                      childCount: 2,
                    ),
                  ),
                ),
                if (popularJamendoTracks != null && popularJamendoTracks.isNotEmpty) ...[
                  // Header for "Popular Jamendo Tracks"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10, left: 10),
                      child: Text(
                        AppLocalizations.of(context)!.popular_jamendo_tracks,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  // Grid for "Popular Jamendo Tracks"
                  SliverPadding(
                    padding: const EdgeInsets.all(5.0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200.0,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
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
                        childCount: popularJamendoTracks.length,
                      ),
                    ),
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
