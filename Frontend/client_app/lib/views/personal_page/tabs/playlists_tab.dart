import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/UserPlaylistsDto.dart';
import 'package:frontend/models/constants/result_card_types.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/services/playlist_service.dart'; // Ensure this service is correctly imported
import 'package:frontend/widgets/cards/result_item_card.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlaylistsTab extends StatefulWidget {
  const PlaylistsTab({super.key});

  @override
  State<PlaylistsTab> createState() => _PlaylistsTabState();
}

class _PlaylistsTabState extends State<PlaylistsTab> {
  final PlaylistService _playlistService = GetIt.I<PlaylistService>();
  Future<List<UserPlaylistsDto>>? _playlistsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playlistsFuture = _playlistService.GetMyPlaylists();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_playlistsFuture != null) {
      // Trigger a rebuild to filter playlists based on the updated search term.
      setState(() {});
    }
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
            hintText: AppLocalizations.of(context)!.search_playlists,
            border: InputBorder.none,
            icon: const Icon(Icons.search),
          ),
        ),
      ),
      body: FutureBuilder<List<UserPlaylistsDto>>(
        future: _playlistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<UserPlaylistsDto> playlists = snapshot.data!;
            // Filter playlists based on the search term
            playlists = playlists.where((playlist) =>
                playlist.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

            if (playlists.isEmpty && _searchController.text.isEmpty) {
              // No playlists found
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context)!.no_playlists,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              );
            } else {
              // Display filtered playlists
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: (4 / 4),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  var playlist = playlists[index];
                  return GestureDetector(
                    onTap: () => GoRouter.of(context).push('/playlist/${playlist.id}/false'),
                    child: ResultItemCard(
                      title: playlist.name,
                      type: ResultCardType.Playlist
                    ),
                  );
                },
              );
            }
          } else {
            // In case no data is available
            return Center(child: Text(AppLocalizations.of(context)!.no_data_available));
          }
        },
      ),
    );
  }
}
