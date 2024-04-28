import 'dart:async';

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
  bool _isWeb = kIsWeb;
  double initialVolume = 0.6;
  Timer? _playTimer;

  bool _isPlaying = false;
  set isPlaying(bool value) {
    if (_isPlaying != value) {
      _isPlaying = value;
      notifyListeners();
      if (_isPlaying) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  StreamingContext? currentStreamingContext;

  bool _trackLoaded = false;
  Duration? _fullDuration;
  Duration? _lastPosition;

  Track? _currentTrack;
  Track? _nextTrack;
  List<Track> _trackHistory = [];
  int previousIndex = -1;

  bool get isPlaying => _isPlaying;
  bool get isLiked => _currentTrack?.isLiked ?? false;
  bool get trackLoaded => _trackLoaded;
  Track? get currentTrack => _currentTrack;
  Track? get nextTrack => _nextTrack;
  List<Track> get trackHistory => _trackHistory;
  String? get currentTrackTitle => _currentTrack?.title;
  String? get currentTrackArtist => _currentTrack?.artist?.user?.userName;
  Duration? get fullDuration => _fullDuration;
  List<int> get trackHistoryIds =>
      _trackHistory.map((track) => track.id).toList();

  MusicStreamer() {
    if(kIsWeb) {
      initialVolume = 0.4;
    }
    _player.setVolume(initialVolume);
    _setupCurrentIndexListener();
  }

  Future<void> startTrack(StreamingContext streamingContext) async {
    if (streamingContext.track.signedUrl != null &&
        streamingContext.track.signedUrl != "") {
      await stop();
      await _clearTrackState();
      await _initializePlaylist(streamingContext.track.signedUrl!);
      await _setCurrentTrackState(streamingContext.track);
      currentStreamingContext = streamingContext;
      _trackHistory.add(streamingContext.track);
      play();
      _prepareNextTrack(streamingContext);
    } else {
      throw Exception('Invalid track URL');
    }
  }

  Future<void> playNextTrack({bool automatic = false}) async {
    try {
      if (!automatic) {
        await stop();
        await _player.seekToNext(); // Just Audio handles the track navigation
        await play();
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
        await stop();
        await _player
            .seekToPrevious(); // Just Audio handles the track navigation
        await play();
      } else {
        await _player.seek(Duration.zero);
      }
    } catch (e) {
      // Handle any errors that might occur during seeking
      print("Error seeking to previous track: $e");
      // Depending on your error handling strategy, you might want to stop playback, seek to the beginning of the current track, or take other actions.
    }
  }

  Future<void> play() async {
    try {
      _player.play();
      isPlaying = true;
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

  Future<void> pause({bool gradually = true}) async {
    await _player.pause();
    isPlaying = false;
    _lastPosition = _player.position;
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _lastPosition = null;
    isPlaying = false;
    notifyListeners();
  }

  void toggleIsLiked() {
    if (_currentTrack != null) {
      if (_currentTrack!.isLiked == null) {
        _currentTrack!.isLiked = true;
      } else {
        _currentTrack!.isLiked = !_currentTrack!.isLiked!;
      }
      notifyListeners();
    }
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

  Future<void> _initializePlaylist(String initialTrackUrl) async {
    String fullUrl = _getFullUrl(initialTrackUrl);
    _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: [AudioSource.uri(Uri.parse(fullUrl))],
    );
    // await _player.stop();
    await _player.setAudioSource(_playlist!,
        preload: false, initialIndex: 0, initialPosition: Duration.zero);
  }

  void _setupCurrentIndexListener() {
    _player.currentIndexStream.listen((currentIndex) async {
      if (_nextTrack != null &&
          currentStreamingContext != null &&
          currentIndex != null) {
        // Play next track
        if (currentIndex >= previousIndex) {
          await _setCurrentTrackState(_nextTrack!);
          _trackHistory.add(_nextTrack!);
          await _prepareNextTrack(currentStreamingContext!);
          // Play previous track
        } else if (currentIndex < previousIndex) {
          Track nextTrack = _trackHistory.removeLast();
          await _setNextTrackState(nextTrack);
          await _setCurrentTrackState(_trackHistory.last);
        }

        previousIndex = currentIndex;
        notifyListeners();
      }
    });
  }

  void _addToPlaylist(String url) {
    String fullUrl = _getFullUrl(url);

    if (_playlist != null) {
      _playlist!.add(AudioSource.uri(Uri.parse(fullUrl)));
    }
  }

  Future<void> _setCurrentTrackState(Track currentTrack) async {
    _currentTrack = currentTrack;
    _trackLoaded = true;
    notifyListeners();
  }

  Future<void> _prepareNextTrack(StreamingContext streamingContext) async {
    // Fetch the next track based on the current streaming context
    streamingContext.trackHistoryIds = trackHistoryIds;
    if (_nextTrack != null) {
      streamingContext.track = _nextTrack!;
    }
    final nextTrack = await _tracksService.getNextTrack(streamingContext);
    streamingContext.resetTimeListened();
    await _setNextTrackState(nextTrack);
    // Add the next track to the playlist
    _addToPlaylist(nextTrack.signedUrl!);
  }

  Future<void> _setNextTrackState(Track nextTrack) async {
    _nextTrack = nextTrack;
    notifyListeners();
  }

  Future<void> _clearTrackState() async {
    _currentTrack = null;
    _nextTrack = null;
    _trackLoaded = false;
    _lastPosition = null;
    isPlaying = false;
    previousIndex = 0;
    _trackHistory = [];
    // Remove the next track from just_audio playlist
    if (_playlist != null) {
      _playlist!.removeAt(_playlist!.length - 1);
    }
    notifyListeners();
  }

  String _getFullUrl(String signedUrl) {
    if (signedUrl.contains("jamendo")) {
      return signedUrl;
    }
    return '$_listenerUrl/Tracks/Stream/$signedUrl';
  }

  void _startTimer() {
    _playTimer?.cancel(); // Ensure only one timer is running
    _playTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (currentStreamingContext != null) {
        currentStreamingContext!.addTimeListened(Duration(seconds: 1));
      }
    });
  }

  void _stopTimer() {
    _playTimer?.cancel();
    _playTimer = null;
  }

  @override
  void dispose() async {
    await stop();
    _player.dispose();
    super.dispose();
  }
}
