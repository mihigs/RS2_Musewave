import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/services/base/api_service.dart';

class AlbumService extends ApiService {
  final FlutterSecureStorage secureStorage;

  AlbumService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<List<Album>> getAlbumsByTitle(String title) async {
    try {
      final response = await httpGet('Album/GetAlbumsByTitle?title=$title');

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to an Album
      final List<Album> result = List.empty(growable: true);

      for (var item in data) {
        result.add(Album.fromJson(item));
      }

      return result;
    } on Exception {
      rethrow;
    }
  }

  Future<Album> GetAlbumDetails(int id) async {
    try {
      final response = await httpGet('Album/GetAlbumDetails/$id');
      
      return _mapToAlbum(response['data']);
    } on Exception {
      rethrow;
    }
  }
}

Album _mapToAlbum(response) {
  if (response == null) {
    throw Exception('Album not found');
  }
  return Album.fromJson(response);
}
