import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Immutable snapshot used in UI
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
  final Map<int, int> _idToIndex = {};

  int currentIndex = 0;

  // ============ Shuffle & Repeat ============
  bool isShuffling = false;
  LoopMode loopMode = LoopMode.off;

  // ============ Combined Position Stream ============
  StreamController<PositionData>? _posDataCtrl;

  Duration _pos = Duration.zero;
  Duration _buff = Duration.zero;
  Duration _dur = Duration.zero;

  StreamSubscription? _posSub;
  StreamSubscription? _buffSub;
  StreamSubscription? _durSub;
  StreamSubscription? _indexSub;
  StreamSubscription? _playingEnforceSub;

  AudioPlayerController() {
    // Track current index changes
    _indexSub = player.currentIndexStream.listen((index) {
      if (index == null) return;
      currentIndex = index;
      notifyListeners();
    });

    // Auto-enforce normal speed
    _playingEnforceSub = player.playingStream.listen((isPlaying) {
      if (isPlaying) {
        try {
          player.setSpeed(1.0);
        } catch (_) {}
      }
    });
  }

  // ===========================================================
  // GETTERS
  // ===========================================================

  SongModel? get currentSong =>
      playlist.isEmpty ? null : playlist[currentIndex];

  int? get currentSongId => currentSong?.id;

  bool get isPlaying => player.playing;

  Stream<bool> get playingStream => player.playingStream;

  // ===========================================================
  // POSITION STREAM
  // ===========================================================

  Stream<PositionData> get positionDataStream {
    _ensurePositionStream();
    return _posDataCtrl!.stream;
  }

  void _ensurePositionStream() {
    if (_posDataCtrl != null) return;

    _posDataCtrl = StreamController<PositionData>.broadcast();

    _posSub = player.positionStream.listen((p) {
      _pos = p;
      _emitData();
    });

    _buffSub = player.bufferedPositionStream.listen((b) {
      _buff = b;
      _emitData();
    });

    _durSub = player.durationStream.listen((d) {
      _dur = d ?? Duration.zero;
      _emitData();
    });
  }

  void _emitData() {
    if (_posDataCtrl == null || _posDataCtrl!.isClosed) return;
    _posDataCtrl!.add(
      PositionData(
        position: _pos,
        bufferedPosition: _buff,
        duration: _dur,
      ),
    );
  }

  // ===========================================================
  // PLAYLIST LOGIC  (Modern JustAudio API)
  // ===========================================================

  Future<void> setPlaylist(
    List<SongModel> songs, {
    int initialIndex = 0,
  }) async {
    playlist = List<SongModel>.from(songs);

    _idToIndex.clear();
    for (int i = 0; i < playlist.length; i++) {
      _idToIndex[playlist[i].id] = i;
    }

    // Use file paths (faster, clean, reliable)
    final sources = playlist
        .map((s) => AudioSource.uri(Uri.file(s.data)))
        .toList();

    await player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );

    // Reset speed to normal
    try {
      await player.setSpeed(1.0);
    } catch (_) {}

    currentIndex = initialIndex;
    notifyListeners();

    await player.play();
  }

  // ===========================================================
  // PLAY SPECIFIC INDEX
  // ===========================================================

  Future<void> playIndex(int index) async {
    if (index < 0 || index >= playlist.length) return;

    currentIndex = index;

    await player.seek(Duration.zero, index: index);

    try {
      await player.setSpeed(1.0);
    } catch (_) {}

    await player.play();
  }

  // Legacy compatibility
  Future<void> playSong(SongModel song) async {
    final idx = _idToIndex[song.id];
    if (idx != null) playIndex(idx);
  }

  // ===========================================================
  // CONTROLS
  // ===========================================================

  void togglePlayPause() {
    player.playing ? player.pause() : player.play();
  }

  void next() => player.seekToNext();

  void previous() => player.seekToPrevious();

  Future<void> seek(Duration position) async => player.seek(position);

  // Playback speed adjustment
  Future<void> setPlaybackSpeed(double speed) async {
    final s = speed.clamp(0.25, 3.0);
    try {
      await player.setSpeed(s);
    } catch (_) {}
  }

  // ===========================================================
  // SHUFFLE + REPEAT LOGIC
  // ===========================================================

  Future<void> toggleShuffle() async {
    isShuffling = !isShuffling;
    await player.setShuffleModeEnabled(isShuffling);
    notifyListeners();
  }

  void toggleRepeat() {
    switch (loopMode) {
      case LoopMode.off:
        loopMode = LoopMode.all;
        break;

      case LoopMode.all:
        loopMode = LoopMode.one;
        break;

      case LoopMode.one:
        loopMode = LoopMode.off;
        break;
    }

    player.setLoopMode(loopMode);
    notifyListeners();
  }

  // ===========================================================
  // CLEANUP
  // ===========================================================

  @override
  void dispose() {
    _posSub?.cancel();
    _buffSub?.cancel();
    _durSub?.cancel();
    _indexSub?.cancel();
    _playingEnforceSub?.cancel();
    _posDataCtrl?.close();
    player.dispose();
    super.dispose();
  }
}
