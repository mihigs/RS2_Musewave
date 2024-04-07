import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/HomepageDetailsDto.dart';
import 'package:frontend/models/constants/names.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/result_item_card.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class ForYouResults extends StatefulWidget {
  ForYouResults({
    super.key,
    // required this.exploreWeeklyPlaylist,
    // required this.likedTracksPlaylist,
    required this.homepageDetails,
  });

  // final Future<Playlist> exploreWeeklyPlaylist;
  // final Future<Playlist> likedTracksPlaylist;
  final Future<HomepageDetailsDto> homepageDetails;

  // final TracksService tracksService = GetIt.I<TracksService>();
  // final PlaylistService playlistService = GetIt.I<PlaylistService>();

  @override
  State<ForYouResults> createState() => _ForYouResultsState();
}

class _ForYouResultsState extends State<ForYouResults> {
  // late Future<Playlist> exploreWeeklyPlaylist;
  // late Future<Playlist> likedTracksPlaylist;
  late Future<HomepageDetailsDto> homepageDetails;

  // void initState() {
  //   super.initState();
  //   exploreWeeklyPlaylist = widget.playlistService.GetExploreWeeklyPlaylist();
  //   likedTracksPlaylist = widget.playlistService.GetLikedTracksPlaylist();
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: Future.wait([
        // exploreWeeklyPlaylist,
        // likedTracksPlaylist,
        widget.homepageDetails,
      ]),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var results = snapshot.data!;
          // var exploreWeeklyPlaylist = results[0] as Playlist;
          // var likedTracksPlaylist = results[1] as Playlist;
          // var homepageDetails = results[0] as HomepageDetailsDto;
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
                            .push('/playlist/${exploreWeeklyPlaylistId}'),
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
                        // Explicitly defining the type here
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
