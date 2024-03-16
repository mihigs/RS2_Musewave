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
  Duration? fullDuration;
  Duration? lastPosition;

  bool get isPlaying => _isPlaying;
  

  Future<void> initializeTrack(String trackSource) async {
    _currentTrackUrl = trackSource;
    String fullUrl = '$listenerUrl/Tracks/Stream/$_currentTrackUrl';
    await stop();
    try{
      fullDuration = await _player.setUrl(fullUrl);
    }
    catch(e){
      rethrow;
    }
  }

  Future<void> initializeAndPlay(String trackSource) async {
    try {
      await initializeTrack(trackSource);
      await play();
    } catch (e) {
      rethrow;      
    }
  }

  Future<void> play() async {
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

  Future<void> resume() async {
    if (_currentTrackUrl != null) {
      if(lastPosition != null){
        await seek(lastPosition!);
        await play();
      }
    }
  }

  Future<void> pause() async {
    lastPosition = _player.position;
    _isPlaying = false;
    notifyListeners();
    await _player.pause();
  }

  Future<void> stop() async {
    lastPosition = null;
    _isPlaying = false;
    notifyListeners();
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }


  Stream<Duration> getPositionStream() {
    return _player.positionStream;
  }

  Stream<Duration> getBufferedPositionStream() {
    return _player.bufferedPositionStream;
  }

  Duration? getDuration() {
    return _player.duration;
  }

}
