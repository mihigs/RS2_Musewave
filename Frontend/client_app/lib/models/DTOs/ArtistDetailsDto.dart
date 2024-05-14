import 'package:frontend/models/artist.dart';
import 'package:frontend/models/track.dart';

class ArtistDetailsDto {
  final Artist artist;
  final List<Track> tracks;

  ArtistDetailsDto({
    required this.artist,
    required this.tracks,
  });

  factory ArtistDetailsDto.fromJson(Map<String, dynamic> json) {
    return ArtistDetailsDto(
      artist: Artist.fromJson(json['artist']),
      tracks: List<Track>.from(json['tracks'].map((track) => Track.fromJson(track))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artist': artist,
      'tracks': tracks,
    };
  }
}