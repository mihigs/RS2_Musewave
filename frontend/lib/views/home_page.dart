import 'package:flutter/material.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/for_you_results.dart';
import 'package:frontend/widgets/navigation_menu.dart';
import 'package:frontend/widgets/search_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.changePage});

  final TracksService tracksService = GetIt.I<TracksService>();
  final PlaylistService playlistService = GetIt.I<PlaylistService>();

  final void Function(int index) changePage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Playlist> exploreWeeklyPlaylist;

  @override
  void initState() {
    super.initState();
    exploreWeeklyPlaylist = widget.playlistService.GetExploreWeeklyPlaylist();
  }

  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10, 35, 10, 10), // left, top, right, bottom
            child: GestureDetector(
              child: AbsorbPointer(
                absorbing: true,
                child: SearchBarWidget(
                  key: null,
                ),
              ),
              onTap: () {
                // Navigate to search
                widget.changePage(1);
              },
            ),
          ),
          Expanded(child: ForYouResults(
            exploreWeeklyPlaylist: exploreWeeklyPlaylist,  
          )),
        ],
      );
  }
}
