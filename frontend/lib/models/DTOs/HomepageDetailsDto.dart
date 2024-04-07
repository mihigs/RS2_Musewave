import 'package:frontend/models/track.dart';

class HomepageDetailsDto {
  final int exploreWeeklyPlaylistId;
  final List<Track> popularJamendoTracks;

  HomepageDetailsDto({
    required this.exploreWeeklyPlaylistId,
    required this.popularJamendoTracks,
  });

  factory HomepageDetailsDto.fromJson(Map<String, dynamic> json) {
    return HomepageDetailsDto(
      exploreWeeklyPlaylistId: json['exploreWeeklyPlaylistId'],
      popularJamendoTracks: List<Track>.from(json['popularJamendoTracks'].map((track) => Track.fromJson(track))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exploreWeeklyPlaylistId': exploreWeeklyPlaylistId,
      'popularJamendoTracks': popularJamendoTracks,
    };
  }
}