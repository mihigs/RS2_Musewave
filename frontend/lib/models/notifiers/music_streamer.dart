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
  final String _listenerUrl = const String.fromEnvironment('LISTENER_URL');

  StreamingContext? currentStreamingContext;

  bool _isPlaying = false;
  bool _trackLoaded = false;
  Duration? _fullDuration;
  Duration? _lastPosition;

  Track? _currentTrack;
  Track? _nextTrack;
  List<Track> _journeyHistoryIds = [];

  bool get isPlaying => _isPlaying;
  bool get trackLoaded => _trackLoaded;
  Track? get currentTrack => _currentTrack;
  Track? get nextTrack => _nextTrack;
  List<Track> get journeyHistoryIds => _journeyHistoryIds;
  String? get currentTrackTitle => _currentTrack?.title;
  String? get currentTrackArtist => _currentTrack?.artist?.user?.userName;
  Duration? get fullDuration => _fullDuration;

  MusicStreamer() {
    setupPlayerStateListener();
  }

  void setupPlayerStateListener() {
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // Automatically fetch and play the next track
        playNextTrack().catchError((error) {
          // handle error
          throw Exception('Error playing next track: $error');
        });
      }
      // handle other states if needed
    });
  }

  // Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> initializeTrack(StreamingContext streamingContext) async {
    await stop();
    currentStreamingContext = streamingContext;
    await setCurrentTrackState(streamingContext.track);
    final nextTrack = await _tracksService.getNextTrack(streamingContext);
    setNextTrackState(nextTrack);
  }

  Future<void> setCurrentTrackState(Track newTrack) async {
    try {
      await stop();
      _currentTrack = newTrack;
      _journeyHistoryIds.add(newTrack);
      _trackLoaded = true;
      _lastPosition = null;
      notifyListeners();
      String fullUrl = '$_listenerUrl/Tracks/Stream/${newTrack.signedUrl}';
      _fullDuration = await _player.setUrl(fullUrl);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setNextTrackState(Track nextTrack) async {
    _nextTrack = nextTrack;
  }

  Future<void> playNextTrack() async {
    try {
      if (_nextTrack != null && currentStreamingContext != null) {
        await setCurrentTrackState(_nextTrack!);
        await stop();
        play();
        final nextTrack =
            await _tracksService.getNextTrack(currentStreamingContext!);
        setNextTrackState(nextTrack);
      } else {
        await stop();
        throw Exception('No next track to play');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> playPreviousTrack() async {
    if (_journeyHistoryIds.length >= 2) {
      await stop();
      Track currentTrack = _journeyHistoryIds.removeLast();
      setNextTrackState(currentTrack!);
      Track previousTrack = _journeyHistoryIds.last;
      await setCurrentTrackState(previousTrack);
      await play();
    } else {
      // seek to the beginning of the track and continue
      await seek(Duration.zero);
      await play();
    }
  }

  Future<void> startTrack(StreamingContext streamingContext) async {
    try {
      await initializeTrack(streamingContext);
      await play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> play() async {
    try {
      _isPlaying = true;
      notifyListeners();
      await _player.play();
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
    _lastPosition = _player.position;
    _isPlaying = false;
    notifyListeners();
    await _player.pause();
  }

  Future<void> stop() async {
    _lastPosition = null;
    _isPlaying = false;
    // _trackLoaded = false;
    notifyListeners();
    await _player.stop();

// await _player.stop().then((value) => {
    //   lastPosition = null,
    //   _isPlaying = false,
    //   trackLoaded = false,
    //   notifyListeners()
    // });
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

  @override
  void dispose() async {
    await stop();
    _player.dispose();
    super.dispose();
  }
}
