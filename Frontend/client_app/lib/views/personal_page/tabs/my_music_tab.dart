import 'package:flutter/material.dart';
import 'package:frontend/models/constants/result_card_types.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/cards/result_item_card.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class MyMusicTab extends StatefulWidget {
  const MyMusicTab({super.key});

  @override
  State<MyMusicTab> createState() => _MyMusicTabState();
}

class _MyMusicTabState extends State<MyMusicTab> {
  final TracksService _tracksService = GetIt.I<TracksService>();
  Future<List<Track>>? _tracksFuture;
  List<Track> _tracks = [];
  List<Track> _filteredTracks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tracksFuture = _loadTracks();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<Track>> _loadTracks() async {
    var tracks = await _tracksService.getMySongs();
    _tracks = tracks;
    return tracks;
  }

  void _onSearchChanged() {
    var searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredTracks = _tracks.where((track) {
        return track.title.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search tracks...',
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
      ),
      body: FutureBuilder<List<Track>>(
        future: _tracksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Track> tracks = snapshot.data!;
            // Filter tracks based on the search term
            tracks = tracks
                .where((track) => track.title
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();

            if (tracks.isEmpty) {
              // No tracks found
              return Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                  child: Column(
                    children: [
                      Text(
                        'Become an artist by uploading your first track',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      IconButton(
                        icon: Icon(Icons.queue),
                        onPressed: () {
                          GoRouter.of(context).push(Routes.uploadMedia);
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Display filtered tracks
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 3),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: (3 / 3.6),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  var track = tracks[index];
                  return ResultItemCard(
                    onTap: () =>
                      GoRouter.of(context).push('/track/${track.id}/0/0'),
                    title: track.title,
                    credits: track.artist?.user?.userName,
                    type: ResultCardType.Track,
                    imageUrl: track.imageUrl,
                  );
                },
              );
            }
          } else {
            // In case no data is available (e.g., an empty future)
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
