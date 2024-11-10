import 'package:flutter/material.dart';
import 'package:frontend/models/constants/result_card_types.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/notifiers/refresh_notifier.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/cards/result_item_card.dart';
import 'package:frontend/widgets/context_menus/my_track_context_menu.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyMusicTab extends StatefulWidget {
  const MyMusicTab({super.key});

  @override
  State<MyMusicTab> createState() => _MyMusicTabState();
}

class _MyMusicTabState extends State<MyMusicTab> {
  final TracksService _tracksService = GetIt.I<TracksService>();
  List<Track> _tracks = [];
  List<Track> _filteredTracks = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTracks();
    _searchController.addListener(_onSearchChanged);

    // Listen for refresh notifications
    GetIt.I<RefreshNotifier>().addListener(_loadTracks);
  }

  Future<void> _loadTracks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final tracks = await _tracksService.getMySongs();
      setState(() {
        _tracks = tracks;
        _filteredTracks = tracks; // Initialize filtered list to show all tracks initially
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final searchTerm = _searchController.text.toLowerCase();
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
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search_tracks,
            border: InputBorder.none,
            icon: const Icon(Icons.search),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _filteredTracks.isEmpty && _searchController.text.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.no_tracks,
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
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 3),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: (3 / 3.6),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _filteredTracks.length,
                      itemBuilder: (context, index) {
                        final track = _filteredTracks[index];
                        return MyTrackContextMenu(
                          trackId: track.id,
                          onDeleteCallback: () {
                            setState(() {
                              _tracks.remove(track);
                              _filteredTracks.remove(track);
                            });
                          },
                          child: ResultItemCard(
                            title: track.title,
                            credits: track.artist?.user?.userName,
                            type: ResultCardType.Track,
                            imageUrl: track.imageUrl,
                            onTap: () =>
                                GoRouter.of(context).push('/track/${track.id}/0/0'),
                          ),
                        );
                      },
                    ),
    );
  }
}
