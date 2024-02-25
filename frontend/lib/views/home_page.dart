import 'package:flutter/material.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/navigation_menu.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title});

  final String title;

  final TracksService tracksService = GetIt.I<TracksService>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Track>> likedTracksFuture;

  @override
  void initState() {
    super.initState();
    likedTracksFuture = widget.tracksService.getLikedTracks();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin:
                EdgeInsets.fromLTRB(10, 35, 10, 10), // left, top, right, bottom
            child: SearchBar(
              key: null,
              onChanged: (value) {
                // Perform the search
              },
            ),
          ),
          Expanded(
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
          )),
        ],
      ),
      bottomNavigationBar: NavigationMenu(),
    );
  }
}
