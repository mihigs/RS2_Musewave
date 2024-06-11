import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/DTOs/Queries/PlaylistQuery.dart';
import 'package:frontend/models/DTOs/UserPlaylistsDto.dart';
import 'package:frontend/models/playlist.dart';
import 'package:frontend/services/base/api_service.dart';

class PlaylistService extends ApiService {
  final FlutterSecureStorage secureStorage;

  PlaylistService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<List<Playlist>> GetPlaylistsByName(String name) async {
    try {
      PlaylistQuery query = PlaylistQuery(name: name);
      final queryParams = query.toQueryParameters();
      final response = await httpGet('Playlist/GetPlaylists', queryParams: queryParams);

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

  Future<Playlist> GetPlaylistDetails(int id) async {
    try {
      final response = await httpGet('Playlist/GetPlaylistDetails?playlistId=$id');

      return _mapToPlaylist(response['data']);

    } on Exception {
      rethrow;
    }
    }

    Future<List<UserPlaylistsDto>> GetMyPlaylists() async {
      try {
        final response = await httpGet('Playlist/GetMyPlaylists');

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

    Future<Playlist> GetMyExploreWeeklyPlaylist() async {
      try {
        final response = await httpGet('Playlist/GetMyExploreWeeklyPlaylist');

        return _mapToPlaylist(response['data']);

      } on Exception {
        rethrow;
      }
    }

    Future<Playlist> GetMyLikedTracksPlaylist() async {
      try {
        final response = await httpGet('Playlist/GetMyLikedTracksPlaylist');

        return _mapToPlaylist(response['data']);

      } on Exception {
        rethrow;
      }
    }

    Future<void> AddToPlaylist(int playlistId, int trackId) async {
      try {
        await httpPost('Playlist/AddTrackToPlaylist', {
          'playlistId': playlistId,
          'trackId': trackId,
        });
      } on Exception {
        rethrow;
      }
    }

    Future<void> CreatePlaylist(String playlistName, int trackId) async {
      try {
        await httpPost('Playlist/CreatePlaylist', {
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

