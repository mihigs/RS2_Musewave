import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/DTOs/UserPlaylistsDto.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/services/base/api_service.dart';

class PlaylistService extends ApiService {
  final FlutterSecureStorage secureStorage;

  PlaylistService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<List<Playlist>> getPlaylistsByName(String name) async {
    try {
      final response = await httpGet('Playlist/GetPlaylistsByName?name=$name');

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to a Playlist
      final List<Playlist> result = List.empty(growable: true);

      for (var item in data) {
        result.add(Playlist.fromJson(item));
      }

      return result;
    } on Exception {
      rethrow;
    }
  }

  Future<Playlist> GetPlaylistDetailsAsync(int id) async {
    try {
      final response = await httpGet('Playlist/GetPlaylistDetailsAsync/$id');

      return _mapToPlaylist(response['data']);

    } on Exception {
      rethrow;
    }
    }

    Future<List<UserPlaylistsDto>> GetUserPlaylists() async {
      try {
        final response = await httpGet('Playlist/GetUserPlaylists');

        List<dynamic> data = List<dynamic>.from(response['data']);

        // Convert each Map to a Playlist
        final List<UserPlaylistsDto> result = List.empty(growable: true);

        for (var item in data) {
          result.add(UserPlaylistsDto.fromJson(item));
        }

        return result;
      } on Exception {
        rethrow;
      }
    }

    Future<Playlist> GetExploreWeeklyPlaylist() async {
      try {
        final response = await httpGet('Playlist/GetExploreWeeklyPlaylist');

        return _mapToPlaylist(response['data']);

      } on Exception {
        rethrow;
      }
    }

    Future<Playlist> GetLikedTracksPlaylist() async {
      try {
        final response = await httpGet('Playlist/GetLikedTracksPlaylist');

        return _mapToPlaylist(response['data']);

      } on Exception {
        rethrow;
      }
    }

    Future<void> AddToPlaylist(int playlistId, int trackId) async {
      try {
        await httpPost('Playlist/AddToPlaylist', {
          'playlistId': playlistId,
          'trackId': trackId,
        });
      } on Exception {
        rethrow;
      }
    }

    Future<void> CreateAndAddToPlaylist(String playlistName, int trackId) async {
      try {
        await httpPost('Playlist/CreateAndAddToPlaylist', {
          'playlistName': playlistName,
          'trackId': trackId,
        });
      } on Exception {
        rethrow;
      }
    }

    Future<void> RemoveTrackFromPlaylist(int playlistId, int trackId) async {
      try {
        await httpPost('Playlist/RemoveTrackFromPlaylist', {
          'playlistId': playlistId,
          'trackId': trackId,
        });
      } on Exception {
        rethrow;
      }
    }
  }
  
  
  Playlist _mapToPlaylist(response) {
    if (response == null) {
      throw Exception('Playlist not found');
    }
    return Playlist.fromJson(response);
  }

