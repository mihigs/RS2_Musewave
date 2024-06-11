import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/helpers/helper_functions.dart';
import 'package:frontend/models/DTOs/Queries/JamendoTrackQuery.dart';
import 'package:frontend/models/DTOs/Queries/TrackQuery.dart';
import 'package:frontend/models/DTOs/TrackUploadDto.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/base/api_service.dart';
import 'package:frontend/services/signalr_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class TracksService extends ApiService {
  final FlutterSecureStorage secureStorage;
  final SignalRService signalrService = GetIt.I<SignalRService>();

  TracksService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<List<Track>> getLikedTracks() async {
    try {
      final response = await httpGet('Tracks/GetMyLikedTracks');

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
      TrackQuery query = TrackQuery(name: name);
      final queryParams = query.toQueryParameters();

      final response = await httpGet('Tracks/GetTracks', queryParams: queryParams);

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

  Future<List<Track>> getJamendoTracksByName(String name) async {
    try {
      JamendoTrackQuery query = JamendoTrackQuery(name: name);
      final queryParams = query.toQueryParameters();
      final response = await httpGet('Tracks/GetJamendoTracks', queryParams: queryParams);

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
    
    var token = await getTokenFromStorage();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Tracks/UploadTrack'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Ensure file.bytes is not null
    if (file.bytes == null) {
      print('File bytes are null, cannot upload');
      return false;
    }

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

    // Check the signalR connection, and reestablish if needed
    if (!signalrService.isConnected) {
      await signalrService.startConnection();
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      print('Uploaded!');
      return true;
    } else {
      print('Failed to upload');
      return false;
    }
  }

  Future<Track> getTrack(int trackId) async {
    try {
      final response = await httpGet('Tracks/GetTrackDetails?trackId=$trackId');
      return _mapToTrack(response['data']);
    } on Exception {
      rethrow;
    }
  }

  Future<Track?> getJamendoTrack(String trackId) async {
    try {
      final response = await httpGet('Tracks/GetJamendoTrackDetails/$trackId');
      if (response == null) {
        return null;
      }
      return _mapToTrack(response['data']);
    } on Exception {
      rethrow;
    }
  }

  Future<StreamedResponse> streamTrack(String trackSource) async {
    var token = await getTokenFromStorage();
    var request = http.Request('GET', Uri.parse(trackSource));
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    var streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      return streamedResponse;
    } else {
      throw Exception('Failed to stream track');
    }
  }

  Future<Track> getNextTrack(StreamingContext streamingContext) async {
    try {
      var data = {
        'CurrentTrackId': streamingContext.track.id.toString(),
        'ContextId': streamingContext.contextId?.toString(),
        'StreamingContextType': getStringFromStreamingContextType(streamingContext.type),
        'TrackHistoryIds': streamingContext.trackHistoryIds,
        'TimeListened': streamingContext.timeListened.inSeconds,
      };
      final response = await httpPost('Tracks/GetNextTrack', data);
      return _mapToTrack(response['data']);
    } on Exception {
      rethrow;
    }
  }

  Future<Track> GetNextPlaylistTrack(String currentTrackId, String playlistId) async {
    try {
      final response = await httpGet('Tracks/GetNextPlaylistTrack/$currentTrackId/$playlistId');
      return _mapToTrack(response['data']);
    } on Exception {
      rethrow;
    }
  }

    Future<Track> GetNextAlbumTrack(String currentTrackId, String albumId) async {
    try {
      final response = await httpGet('Tracks/GetNextAlbumTrack/$currentTrackId/$albumId');
      return _mapToTrack(response['data']);
    } on Exception {
      rethrow;
    }
  }

  Future<bool> toggleLikeTrack(int trackId) async {
    try {
      final response = await httpPost('Tracks/ToggleLikeTrack?trackId=$trackId', null);
      return response != null;
    } on Exception {
      rethrow;
    }
  } 

  Future<List<Track>> getMySongs() async {
    try {
      final response = await httpGet('Tracks/GetMyTracks');

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

  Future<List<Comment>> getTrackComments(int trackId) async {
    try {
      final response = await httpGet('Tracks/GetTrackComments?trackId=$trackId');

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to a Track
      final List<Comment> result = List.empty(growable: true);
      for (var item in data) {
        result.add(Comment.fromJson(item));
      }
      return result;
    } on Exception {
      rethrow;
    }
  }

Future<Comment?> addTrackComment(int trackId, String comment) async {
  try {
    final response = await httpPost('Tracks/AddTrackComment', {'trackId': trackId, 'comment': comment});

    Comment newComment = Comment.fromJson(response['data']);
    return newComment;

  } on Exception catch (e) {
    // Handle exceptions
    print(e);
    return null;
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
