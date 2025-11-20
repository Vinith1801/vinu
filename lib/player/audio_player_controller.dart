import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  final Map<int, Uri?> _artCache = {};
  Directory? _artDir;

  int currentIndex = 0;

  // Shuffle & Repeat
  bool isShuffling = false;
  LoopMode loopMode = LoopMode.off;

  // Position stream merge (keeps a lightweight controller)
  StreamController<PositionData>? _posDataCtrl;
  Duration _pos = Duration.zero;
  Duration _buff = Duration.zero;
  Duration _dur = Duration.zero;
  StreamSubscription? _posSub;
  StreamSubscription? _buffSub;
  StreamSubscription? _durSub;
  StreamSubscription? _indexSub;

  // OnAudioQuery instance (reused)
  final OnAudioQuery _audioQuery = OnAudioQuery();

  AudioPlayerController() {
    _init();
  }

  Future<void> _init() async {
    // Configure audio session
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {}

    // prepare art directory
    _artDir = await _getArtDirectory();

    // Track index changes
    _indexSub = player.currentIndexStream.listen((index) {
      if (index == null) return;
      currentIndex = index;
      notifyListeners();
    });

    // Create position stream merge lazily later when requested
  }

  // ---------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------
  SongModel? get currentSong => playlist.isEmpty ? null : playlist[currentIndex];
  int? get currentSongId => currentSong?.id;
  bool get isPlaying => player.playing;
  Stream<bool> get playingStream => player.playingStream;

  // ---------------------------------------------------------
  // POSITION STREAM MERGE
  // ---------------------------------------------------------
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
    _posDataCtrl!.add(PositionData(position: _pos, bufferedPosition: _buff, duration: _dur));
  }
  // ---------------------------------------------------------
  // ARTWORK CACHING
  // ---------------------------------------------------------

  Future<Directory> _getArtDirectory() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appDir.path, 'artwork_cache'));
    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } catch (_) {}
    }
    return dir;
  }

  Uri? getCachedArtworkUri(int songId) {
    // synchronous fast hit (may be null)
    return _artCache[songId];
  }

  Future<Uri?> ensureArtworkForId(int songId) async {
    // quick in-memory hit
    if (_artCache.containsKey(songId)) return _artCache[songId];

    // ensure art dir ready
    _artDir ??= await _getArtDirectory();
    final targetFile = File(p.join(_artDir!.path, '${songId}_art.jpg'));

    // if file already exists on disk, use it
    if (await targetFile.exists()) {
      final uri = Uri.file(targetFile.path);
      _artCache[songId] = uri;
      return uri;
    }

    // query artwork bytes (this is the expensive part; only happens once per song)
    try {
      final bytes = await _audioQuery.queryArtwork(songId, ArtworkType.AUDIO);
      if (bytes == null) {
        _artCache[songId] = null;
        return null;
      }

      await targetFile.writeAsBytes(bytes, flush: true);
      final uri = Uri.file(targetFile.path);
      _artCache[songId] = uri;
      return uri;
    } catch (e) {
      // on any failure, cache null to avoid repeated failing attempts
      _artCache[songId] = null;
      return null;
    }
  }

  // ---------------------------------------------------------
  // SET PLAYLIST (non-blocking, optimized)
  // ---------------------------------------------------------
  Future<void> setPlaylist(
    List<SongModel> songs, {
    int initialIndex = 0,
  }) async {
    if (songs.isEmpty) return;

    if (_samePlaylistById(playlist, songs)) {
      _rebuildIdLookup(songs);
      await playIndex(initialIndex);
      return;
    }

    playlist = List<SongModel>.from(songs);
    _rebuildIdLookup(playlist);

    final children = <AudioSource>[];

    for (final s in playlist) {
      // Get or build the artwork first
      final artUri = await ensureArtworkForId(s.id);

      final mediaItem = MediaItem(
        id: s.id.toString(),
        title: s.title,
        album: s.album ?? '',
        artist: s.artist ?? '',
        artUri: artUri,
        extras: {'uri': s.data},
      );

      children.add(
        AudioSource.uri(
          Uri.file(s.data),
          tag: mediaItem,
        ),
      );
    }

    final concat = ConcatenatingAudioSource(children: children);

    await player.setAudioSource(
      concat,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );

    try {
      await player.setSpeed(1.0);
    } catch (_) {}

    currentIndex = initialIndex;
    notifyListeners();
    await player.play();
  }

  bool _samePlaylistById(List<SongModel> a, List<SongModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _rebuildIdLookup(List<SongModel> list) {
    _idToIndex.clear();
    for (int i = 0; i < list.length; i++) _idToIndex[list[i].id] = i;
  }

  // ---------------------------------------------------------
  // PLAY SPECIFIC TRACK (INSTANT)
  // ---------------------------------------------------------
  Future<void> playIndex(int index) async {
    if (index < 0 || index >= playlist.length) return;
    currentIndex = index;
    await player.seek(Duration.zero, index: index);
    await player.play();
  }

  Future<void> playSong(SongModel song) async {
    final idx = _idToIndex[song.id];
    if (idx != null) await playIndex(idx);
  }

  // ---------------------------------------------------------
  // CONTROLS
  // ---------------------------------------------------------
  void togglePlayPause() {
    player.playing ? player.pause() : player.play();
  }

  void next() => player.seekToNext();
  void previous() => player.seekToPrevious();
  Future<void> seek(Duration position) async => player.seek(position);

  Future<void> setPlaybackSpeed(double speed) async {
    final s = speed.clamp(0.25, 3.0);
    try {
      await player.setSpeed(s);
    } catch (_) {}
  }

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

  // ---------------------------------------------------------
  // CLEANUP
  // ---------------------------------------------------------
  @override
  void dispose() {
    _posSub?.cancel();
    _buffSub?.cancel();
    _durSub?.cancel();
    _indexSub?.cancel();
    _posDataCtrl?.close();
    player.dispose();
    super.dispose();
  }
}
