import 'package:flutter/foundation.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicStreamer extends ChangeNotifier {
  final TracksService tracksService = GetIt.I<TracksService>();
  final AudioPlayer _player = AudioPlayer();
  final String listenerUrl = const String.fromEnvironment('LISTENER_URL');

  bool _isPlaying = true;
  String? _currentTrackUrl;

  bool get isPlaying => _isPlaying;

  Future<String> initializeTrack(String trackSource) async {
    _currentTrackUrl = trackSource;
    await _player.stop();
    _isPlaying = false;
    notifyListeners();
    String fullUrl = '$listenerUrl/Tracks/Stream/$_currentTrackUrl';
    await _player.setUrl(fullUrl);

    return _currentTrackUrl!;
  }

  Future<void> play() async {
    _isPlaying = false;
    notifyListeners(); // Notify listeners to show loading spinner

    try {
      if (_currentTrackUrl != null) {
        _isPlaying = true;
        notifyListeners();
        await _player.play();
      } else {
        throw Exception('Track URL is null');
      }
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> initializeAndPlay(String trackSource) async {
    await initializeTrack(trackSource);
    await play();
  }

}
