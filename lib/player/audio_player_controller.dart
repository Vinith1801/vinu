import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Simple immutable snapshot for UI position-related data
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });
}

class AudioPlayerController extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();

  List<SongModel> playlist = [];
  Map<int, int> _idToIndex = {};

  /// Expose the current index (mirrors player.currentIndex)
  int currentIndex = 0;

  // Combined position stream controller & subscriptions
  StreamController<PositionData>? _positionDataController;
  Stream<PositionData> get positionDataStream {
    _ensurePositionDataStream();
    return _positionDataController!.stream;
  }

  // keep last known values
  Duration _lastPosition = Duration.zero;
  Duration _lastBuffered = Duration.zero;
  Duration _lastDuration = Duration.zero;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _buffSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<int?>? _indexSub;

  /// Provide lightweight getters used by UI Selectors
  SongModel? get currentSong => playlist.isEmpty ? null : playlist[currentIndex];
  int? get currentSongId => currentSong?.id;
  bool get isPlaying => player.playing;

  AudioPlayerController() {
    // Ensure we notify only on track (index) change
    _indexSub = player.currentIndexStream.listen((index) {
      if (index == null) return;
      currentIndex = index;
      notifyListeners(); // only when current track changes
    });

    // Optionally, you can forward playerState changes to listeners when needed
    // player.playerStateStream.listen((state) { ... });
  }

  /// Builds and sets a concatenated source from a list of SongModel
  Future<void> setPlaylist(List<SongModel> songs, {int initialIndex = 0}) async {
    playlist = List<SongModel>.from(songs);
    _idToIndex = <int, int>{};
    for (var i = 0; i < playlist.length; i++) {
      _idToIndex[playlist[i].id] = i;
    }

    final concat = ConcatenatingAudioSource(
      children: playlist
          .map((s) => AudioSource.uri(Uri.parse(s.uri!)))
          .toList(growable: false),
    );

    try {
      await player.setAudioSource(concat, initialIndex: initialIndex);
      currentIndex = initialIndex;
      notifyListeners();
    } catch (e) {
      debugPrint("Error setting playlist: $e");
    }
  }

  /// Play by index (preferred; fast, no re-creating audio sources)
  Future<void> playIndex(int index) async {
    if (index < 0 || index >= playlist.length) return;
    currentIndex = index;
    await player.seek(Duration.zero, index: index);
    await player.play();
    // currentIndexStream listener will call notifyListeners
  }

  /// Play by SongModel (uses id -> index map to avoid O(n) scans)
  Future<void> playSong(SongModel song) async {
    final idx = _idToIndex[song.id];
    if (idx != null) {
      return playIndex(idx);
    } else {
      // fallback: set playlist and play first occurrence
      final i = playlist.indexWhere((s) => s.id == song.id);
      if (i != -1) return playIndex(i);
      // not found: add to playlist end (optional) — keep simple and return
    }
  }

  void togglePlayPause() {
    player.playing ? player.pause() : player.play();
    // Do NOT call notifyListeners here — let UI listen to player's streams selectively
  }

  void next() => player.seekToNext();
  void previous() => player.seekToPrevious();
  Future<void> seek(Duration position) => player.seek(position);

  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration> get bufferedPositionStream => player.bufferedPositionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<int?> get currentIndexStream => player.currentIndexStream;
  Stream<bool> get playingStream =>
      player.playingStream.map((p) => p); // already a Stream<bool>

  // -----------------------
  // PositionData stream logic (no external dependencies)
  // -----------------------
  void _ensurePositionDataStream() {
    if (_positionDataController != null) return;
    _positionDataController = StreamController<PositionData>.broadcast(
      onListen: () {},
      onCancel: () {},
    );

    _posSub = player.positionStream.listen((p) {
      _lastPosition = p;
      _emitPositionData();
    });

    _buffSub = player.bufferedPositionStream.listen((b) {
      _lastBuffered = b;
      _emitPositionData();
    });

    _durSub = player.durationStream.listen((d) {
      _lastDuration = d ?? Duration.zero;
      _emitPositionData();
    });
  }

  void _emitPositionData() {
    if (_positionDataController == null ||
        _positionDataController!.isClosed) return;
    _positionDataController!.add(
      PositionData(
        position: _lastPosition,
        bufferedPosition: _lastBuffered,
        duration: _lastDuration,
      ),
    );
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _buffSub?.cancel();
    _durSub?.cancel();
    _indexSub?.cancel();
    _positionDataController?.close();
    player.dispose();
    super.dispose();
  }
}
