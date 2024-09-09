import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/UserPlaylistsDto.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddToPlaylistModal extends StatefulWidget {
  final String trackId;

  AddToPlaylistModal({Key? key, required this.trackId}) : super(key: key);

  @override
  _AddToPlaylistModalState createState() => _AddToPlaylistModalState();
}

class _AddToPlaylistModalState extends State<AddToPlaylistModal> {
  final PlaylistService playlistService = GetIt.I<PlaylistService>();
  late Future<List<UserPlaylistsDto>> playlistsFuture;
  final TextEditingController _newPlaylistController = TextEditingController();
  Map<int, bool> playlistTrackStatus = {};

  @override
  void initState() {
    super.initState();
    playlistsFuture = playlistService.GetMyPlaylists().then((playlists) {
      // Initialize the map based on whether each playlist contains the track
      playlistTrackStatus = {
        for (var playlist in playlists)
          playlist.id: playlist.trackIds.contains(int.parse(widget.trackId))
      };
      return playlists;
    });
  }

  void toggleTrackInPlaylist(int playlistId, bool isInPlaylist) {
    // Update the local state immediately for a responsive UI
    setState(() {
      playlistTrackStatus[playlistId] = isInPlaylist;
    });

    // Then update the backend
    if (isInPlaylist) {
      playlistService.AddToPlaylist(playlistId, int.parse(widget.trackId));
    } else {
      playlistService.RemoveTrackFromPlaylist(
          playlistId, int.parse(widget.trackId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(AppLocalizations.of(context)!.add_to_playlist),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _newPlaylistController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.add_to_new_playlist,
                suffixIcon: _newPlaylistController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () async {
                          await playlistService.CreatePlaylist(
                              _newPlaylistController.text,
                              int.parse(widget.trackId));
                          Navigator.of(context).pop();
                        },
                      ),
              ),
              onChanged: (value) {
                setState(() {}); // To update the visibility of the suffix icon
              },
              onSubmitted: (value) async {
                await playlistService.CreatePlaylist(
                    _newPlaylistController.text, int.parse(widget.trackId));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.playlist_created),
                  duration: Duration(seconds: 1),
                ));
                Navigator.of(context).pop();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserPlaylistsDto>>(
              future: playlistsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.no_playlist_found));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    UserPlaylistsDto playlist = snapshot.data![index];
                    bool isTrackInPlaylist =
                        playlistTrackStatus[playlist.id] ?? false;

                    return ListTile(
                      title: Text(playlist.name),
                      trailing: Checkbox(
                        value: isTrackInPlaylist,
                        onChanged: (bool? checked) {
                          toggleTrackInPlaylist(playlist.id, checked ?? false);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
