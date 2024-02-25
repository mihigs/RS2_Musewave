import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/base/api_service.dart';

class TracksService extends ApiService{
  final FlutterSecureStorage secureStorage;

  TracksService(this.secureStorage) : super(secureStorage: secureStorage);

  // Future<List<Track>> getLikedTracks() async {
  //   var response = await httpGet('Tracks/GetLikedTracks');

  //   response = response.data;
  //   // final result = <Track>[];
  //   // for (var track in response) {
  //   //   result.add(Track.fromJson(track));
  //   // }

  //   final result = new Future<List<Track>>.value(response.map((track) => Track.fromJson(track)).toList());

  //   return result;
  // }
Future<List<Track>> getLikedTracks() async {
  final response = await httpGet('Tracks/GetLikedTracks');

  // Ensure that response.data is a List
  // if (response.data is! List) {
  //   throw Exception('Invalid data format');
  // }

  List<dynamic> data = List<dynamic>.from(response['data']);

  // Convert each Map to a Track
  final List<Track> result = List.empty(growable: true);

  for (var item in data) {
    result.add(Track.fromJson(item));
  }

  return result;
}

Track _mapToTrack(dynamic item) {
  if (item is Map<String, dynamic>) {
    return Track.fromJson(item);
  } else {
    throw Exception('Invalid track data');
  }
}



}
