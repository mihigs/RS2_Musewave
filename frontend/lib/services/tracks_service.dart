import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/base/api_service.dart';

class TracksService extends ApiService {
  final FlutterSecureStorage secureStorage;

  TracksService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<List<Track>> getLikedTracks() async {
    try {
      final response = await httpGet('Tracks/GetLikedTracks');

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to a Track
      final List<Track> result = List.empty(growable: true);

      for (var item in data) {
        result.add(Track.fromJson(item));
      }

      return result;
    } on Exception {
      rethrow;
    }
  }

  Future<List<Track>> getTracksByName(String name) async {
    try {
      final response = await httpGet('Tracks/GetTracksByName?name=$name');

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to a Track
      final List<Track> result = List.empty(growable: true);

      for (var item in data) {
        result.add(Track.fromJson(item));
      }

      return result;
    } on Exception {
      rethrow;
    }
  }

  Track _mapToTrack(dynamic item) {
    if (item is Map<String, dynamic>) {
      return Track.fromJson(item);
    } else {
      throw Exception('Invalid track data');
    }
  }
}
