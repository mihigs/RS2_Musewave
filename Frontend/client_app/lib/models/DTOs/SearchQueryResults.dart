import 'package:frontend/models/track.dart';
import 'package:frontend/models/album.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/models/playlist.dart';

class SearchQueryResults {
  final List<Track> tracks;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Track> jamendoTracks;
  final List<Playlist> playlists;

  SearchQueryResults({
    required this.tracks,
    required this.albums,
    required this.artists,
    required this.jamendoTracks,
    required this.playlists,
  });

  factory SearchQueryResults.fromJson(Map<String, dynamic> json) {
    return SearchQueryResults(
      tracks: List<Track>.from(json['tracks'].map((track) => Track.fromJson(track))),
      albums: List<Album>.from(json['albums'].map((album) => Album.fromJson(album))),
      artists: List<Artist>.from(json['artists'].map((artist) => Artist.fromJson(artist))),
      jamendoTracks: List<Track>.from(json['jamendoTracks'].map((track) => Track.fromJson(track))),
      playlists: List<Playlist>.from(json['playlists'].map((playlist) => Playlist.fromJson(playlist))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'albums': albums.map((album) => album.toJson()).toList(),
      'artists': artists.map((artist) => artist.toJson()).toList(),
      'jamendoTracks': jamendoTracks.map((track) => track.toJson()).toList(),
      'playlists': playlists.map((playlist) => playlist.toJson()).toList(),
    };
  }
}
