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
  int previousIndex = -1;

  bool get isPlaying => _isPlaying;
  bool get trackLoaded => _trackLoaded;
  Track? get currentTrack => _currentTrack;
  Track? get nextTrack => _nextTrack;
  List<Track> get trackHistory => _trackHistory;
  String? get currentTrackTitle => _currentTrack?.title;
  String? get currentTrackArtist => _currentTrack?.artist?.user?.userName;
  Duration? get fullDuration => _fullDuration;
  List<int> get trackHistoryIds => _trackHistory.map((track) => track.id).toList();

  MusicStreamer() {
    _player.setVolume(0.3);
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
      if(_nextTrack != null && currentStreamingContext != null && currentIndex != null){
        // Play next track
        if(currentIndex > previousIndex){
          await setCurrentTrackState(_nextTrack!);
          _trackHistory.add(_nextTrack!);
          await _prepareNextTrack(currentStreamingContext!);
        // Play previous track
        }else{
          Track nextTrack = _trackHistory.removeLast();
          await setNextTrackState(nextTrack);
          await setCurrentTrackState(_trackHistory.last);
        }
        previousIndex = currentIndex;
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
    _trackLoaded = true;
    notifyListeners();
  }

  Future<void> _prepareNextTrack(StreamingContext streamingContext) async {
    // Fetch the next track based on the current streaming context
    streamingContext.trackHistoryIds = trackHistoryIds;
    if(_nextTrack != null){
      streamingContext.track = _nextTrack!;
    }
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
        await _player.seekToPrevious(); // Just Audio handles the track navigation
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
