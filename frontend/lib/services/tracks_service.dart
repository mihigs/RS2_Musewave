import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/DTOs/TrackUploadDto.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/base/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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

  Future<bool> uploadTrack(
      TrackUploadDto trackUploadDto, PlatformFile file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://localhost:7151/api/Tracks/UploadTrack'),
    );

    // Add file to the request
    request.files.add(
      http.MultipartFile.fromBytes(
        'mediaFile',
        file.bytes!,
        filename: file.name,
        contentType: MediaType('audio', file.extension!),
      ),
    );

    // Add additional data to the request
    request.fields['trackName'] = trackUploadDto.trackName;
    request.fields['userId'] = trackUploadDto.userId;
    if (trackUploadDto.albumId != null) {
      request.fields['albumId'] = trackUploadDto.albumId!;
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Uploaded!');
      return true;
    } else {
      print('Failed to upload');
      return false;
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
