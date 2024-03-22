import 'package:flutter/foundation.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicStreamer extends ChangeNotifier {
  final TracksService _tracksService = GetIt.I<TracksService>();
  final AudioPlayer _player = AudioPlayer();
  ConcatenatingAudioSource? _playlist;
  final String _listenerUrl = const String.fromEnvironment('LISTENER_URL');

  StreamingContext? currentStreamingContext;

  bool _isPlaying = false;
  bool _trackLoaded = false;
  Duration? _fullDuration;
  Duration? _lastPosition;

  Track? _currentTrack;
  Track? _nextTrack;
  List<Track> _trackHistory = [];

  bool get isPlaying => _isPlaying;
  bool get trackLoaded => _trackLoaded;
  Track? get currentTrack => _currentTrack;
  Track? get nextTrack => _nextTrack;
  List<Track> get trackHistory => _trackHistory;
  String? get currentTrackTitle => _currentTrack?.title;
  String? get currentTrackArtist => _currentTrack?.artist?.user?.userName;
  Duration? get fullDuration => _fullDuration;

  MusicStreamer() {
    _player.setVolume(0.5);
    setupCurrentIndexListener();
  }

  Future<void> initializePlaylist(String initialTrackUrl) async {
    String fullUrl = getFullUrl(initialTrackUrl);
    _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: [AudioSource.uri(Uri.parse(fullUrl))],
    );
    await _player.stop();
    await _player.setAudioSource(_playlist!,
        preload: false, initialIndex: 0, initialPosition: Duration.zero);
  }

  void setupCurrentIndexListener() {
    _player.currentIndexStream.listen((currentIndex) async {
      if(_nextTrack != null && currentStreamingContext != null){
        await setCurrentTrackState(_nextTrack!);
        _trackHistory.add(_nextTrack!);
        await _prepareNextTrack(currentStreamingContext!);
        notifyListeners();
      }
    });
  }

  Future<void> startTrack(StreamingContext streamingContext) async {
    if (streamingContext.track.signedUrl != null ||
        streamingContext.track.signedUrl != "") {
      await stop();
      await clearTrackState();
      await initializePlaylist(streamingContext.track.signedUrl!);
      await setCurrentTrackState(streamingContext.track);
      currentStreamingContext = streamingContext;
      _trackHistory.add(streamingContext.track);
      play();
      _prepareNextTrack(streamingContext);
    } else {
      throw Exception('Invalid track URL');
    }
  }

  void addToPlaylist(String url) {
    String fullUrl = getFullUrl(url);
    if (_playlist != null) {
      _playlist!.add(AudioSource.uri(Uri.parse(fullUrl)));
    }
  }

  Future<void> setCurrentTrackState(Track currentTrack) async {
    _currentTrack = currentTrack;
    notifyListeners();
  }

  Future<void> _prepareNextTrack(StreamingContext streamingContext) async {
    // Fetch the next track based on the current streaming context
    final nextTrack = await _tracksService.getNextTrack(streamingContext);
    await setNextTrackState(nextTrack);
    // Add the next track to the playlist
    addToPlaylist(nextTrack.signedUrl!);
  }

  Future<void> setNextTrackState(Track nextTrack) async {
    _nextTrack = nextTrack;
    notifyListeners();
  }

  Future<void> clearTrackState() async {
    _currentTrack = null;
    _nextTrack = null;
    _trackLoaded = false;
    _lastPosition = null;
    _isPlaying = false;
    // currentStreamingContext = null;
    await _playlist?.clear();
    notifyListeners();
  }

  Future<void> playNextTrack({bool automatic = false}) async {
    try {
      if (!automatic) {
        await _player.seekToNext(); // Just Audio handles the track navigation
      } else {
        // await seek(Duration.zero);
      }
    } catch (e) {
      // Handle any errors that might occur during seeking
      print("Error seeking to next track: $e");
      // Depending on your error handling strategy, you might want to take specific actions, like stopping playback or looping back to the first track in a playlist.
    }
  }

  Future<void> playPreviousTrack() async {
    try {
      if (_player.hasPrevious) {
        Track nextTrack = _trackHistory.removeLast();
        await setNextTrackState(nextTrack);
        await setCurrentTrackState(_trackHistory.last);
        await _player
            .seekToPrevious(); // Just Audio handles the track navigation
      } else {
        await _player.seek(Duration.zero);
      }
      // Optionally, update any relevant state or UI after seeking to the previous track
      notifyListeners();
    } catch (e) {
      // Handle any errors that might occur during seeking
      print("Error seeking to previous track: $e");
      // Depending on your error handling strategy, you might want to stop playback, seek to the beginning of the current track, or take other actions.
    }
  }

  Future<void> play() async {
    try {
      _player.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> resume() async {
    try {
      if (_lastPosition != null) {
        await seek(_lastPosition!);
      }
      await play();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _lastPosition = _player.position;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _lastPosition = null;
    _isPlaying = false;
    notifyListeners();
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

  Stream<PlayerState> getPlayerStateStream() {
    return _player.playerStateStream;
  }

  String getFullUrl(String signedUrl) {
    return '$_listenerUrl/Tracks/Stream/$signedUrl';
  }

  @override
  void dispose() async {
    await stop();
    _player.dispose();
    super.dispose();
  }
}


  // void setupPlayerStateListener() {
  //   _player.playerStateStream.listen((playerState) {
  //     if (playerState.processingState == ProcessingState.completed) {
  //       // Automatically fetch and play the next track
  //       playNextTrack().catchError((error) {
  //         // handle error
  //         throw Exception('Error playing next track: $error');
  //       });
  //     }
  //     // handle other states if needed
  //   });
  // }

  // Future<void> initializeTrack(StreamingContext streamingContext) async {
  //   await stop();
  //   currentStreamingContext = streamingContext;
  //   await setCurrentTrackState(streamingContext.track);
  //   final nextTrack = await _tracksService.getNextTrack(streamingContext);
  //   setNextTrackState(nextTrack);
  // }

  
  // Future<void> startTrack(StreamingContext streamingContext) async {
  //   try {
  //     await initializeTrack(streamingContext);
  //     await play();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  
  // Future<void> playPreviousTrack() async {
  //   if (_journeyHistoryIds.length >= 2) {
  //     await stop();
  //     Track currentTrack = _journeyHistoryIds.removeLast();
  //     setNextTrackState(currentTrack);
  //     Track previousTrack = _journeyHistoryIds.last;
  //     await setCurrentTrackState(previousTrack);
  //     await play();
  //   } else {
  //     // seek to the beginning of the track and continue
  //     await seek(Duration.zero);
  //     await play();
  //   }
  // }
  //
    // Future<void> setCurrentTrackState(Track newTrack) async {
  //   try {
  //     await stop();
  //     _currentTrack = newTrack;
  //     // _journeyHistoryIds.add(newTrack);
  //     _trackLoaded = true;
  //     _lastPosition = null;
  //     notifyListeners();
  //     String fullUrl = '$_listenerUrl/Tracks/Stream/${newTrack.signedUrl}';
  //     _fullDuration = await _player.setUrl(fullUrl);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

    // Future<void> playNextTrack() async {
  //   try {
  //     if (_nextTrack != null && currentStreamingContext != null) {
  //       await setCurrentTrackState(_nextTrack!);
  //       await stop();
  //       await play();
  //       final nextTrack =
  //           await _tracksService.getNextTrack(currentStreamingContext!);
  //       setNextTrackState(nextTrack);
  //     } else {
  //       await stop();
  //       throw Exception('No next track to play or invalid streaming context');
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
