import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/UserPlaylistsDto.dart';
import 'package:frontend/models/constants/result_card_types.dart';
import 'package:frontend/services/notifiers/refresh_notifier.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/widgets/cards/result_item_card.dart';
import 'package:frontend/widgets/context_menus/playlist_context_menu.dart';
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
  List<UserPlaylistsDto> _playlists = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
    _searchController.addListener(_onSearchChanged);
    
    // Listen for refresh notifications
    GetIt.I<RefreshNotifier>().addListener(_fetchPlaylists);
  }

  void _fetchPlaylists() {
    setState(() => _isLoading = true); // Show loading indicator on refetch
    _playlistService.GetMyPlaylists().then((value) {
      setState(() {
        _playlists = value;
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    });
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    GetIt.I<RefreshNotifier>().removeListener(_fetchPlaylists);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<UserPlaylistsDto> filteredPlaylists = _playlists.where((playlist) =>
        playlist.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : filteredPlaylists.isEmpty && _searchController.text.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.no_playlists,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: (4 / 4),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredPlaylists.length,
                      itemBuilder: (context, index) {
                        var playlist = filteredPlaylists[index];
                        return PlaylistContextMenu(
                          playlistId: playlist.id,
                          onDeleteCallback: () {
                            setState(() {
                              _playlists.removeWhere((p) => p.id == playlist.id);
                            });
                          },
                          child: GestureDetector(
                            onTap: () => GoRouter.of(context).push('/playlist/${playlist.id}/false'),
                            child: ResultItemCard(
                              title: playlist.name,
                              type: ResultCardType.Playlist,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
