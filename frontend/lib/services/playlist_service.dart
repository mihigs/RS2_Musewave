import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  }
  
  Playlist _mapToPlaylist(response) {
    if (response == null) {
      throw Exception('Playlist not found');
    }
    return Playlist.fromJson(response);
  }

