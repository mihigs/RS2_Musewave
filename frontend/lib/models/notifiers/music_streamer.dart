import 'package:flutter/foundation.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicStreamer extends ChangeNotifier {
  final TracksService tracksService = GetIt.I<TracksService>();
  final AudioPlayer _player = AudioPlayer();
  late Future<void> _initializeVideoPlayerFuture;
  final String listenerUrl = const String.fromEnvironment('LISTENER_URL');

  bool _isPlaying = false;
  String? _currentTrackUrl;
  Track? _currentTrack;

  bool get isPlaying => _isPlaying;

  Future<String> initializeTrack(Track track) async {
    _currentTrack = track;
    _currentTrackUrl = track.signedUrl;

    String fullUrl = '$listenerUrl/Tracks/Stream/$_currentTrackUrl';
    await _player.setUrl(fullUrl);

    return _currentTrackUrl!;
  }

  Future<void> play() async {
    _isPlaying = false;
    notifyListeners(); // Notify listeners to show loading spinner

    if (_currentTrack == null) {
      return;
    }

    try {
      if (_currentTrackUrl != null) {
        _player.play();
        _isPlaying = true;
      } else {
        throw Exception('Track URL is null');
      }
    } catch (e) {
      // Handle error
    }

    notifyListeners(); // Notify listeners to hide loading spinner and update play state
  }

  void pause() {
    _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

}


// class MusicStreamer extends ChangeNotifier {
//   final TracksService tracksService = GetIt.I<TracksService>();
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   bool _isPlaying = false;
//   // String? _currentTrackId;
//   String? _currentTrackUrl;
//   Track? _currentTrack;

//   bool get isPlaying => _isPlaying;
//   // String? get currentTrackId => _currentTrackId;
//   // String? get currentTrackUrl => _currentTrackUrl;

//   Future<String> initializeTrack(Track track) async {
//     _currentTrack = track;
//     _currentTrackUrl = track.signedUrl;
//     return _currentTrackUrl!;
//   }

//   Future<void> play() async {
//     _isPlaying = false;
//     notifyListeners(); // Notify listeners to show loading spinner
//     if(_currentTrack == null) {
//       return;
//     }
//     try {
//       if(_currentTrackUrl != null){
//         var streamedResponse = await tracksService.streamTrack(_currentTrackUrl!);
//         // _audioPlayer.setUrl(_currentTrackUrl!);
//         String url = streamedResponse.request?.url.toString() ?? '';

//         // if on web, use just_audio for web
//         if(kIsWeb){
//           await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
//         }
//         else{
//           await _audioPlayer.setUrl(url);
//         }
//         await _audioPlayer.play();
//         _isPlaying = true;
//       }
//       else{
//         throw Exception('Track URL is null');
//       }
//     } catch (e) {
//       // Handle error
//     }

//     notifyListeners(); // Notify listeners to hide loading spinner and update play state
//   }

//   void pause() {
//     _audioPlayer.stop();
//     _isPlaying = false;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
// }
