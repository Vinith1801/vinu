//lib/player/audio_player_controller.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

  bool isShuffling = false;
  LoopMode loopMode = LoopMode.off;

  bool _isPlaying = false;
  StreamSubscription<bool>? _playingSub;

  StreamController<PositionData>? _posCtrl;
  Duration _pos = Duration.zero;
  Duration _buff = Duration.zero;
  Duration _dur = Duration.zero;

  StreamSubscription? _posSub;
  StreamSubscription? _buffSub;
  StreamSubscription? _durSub;
  StreamSubscription? _indexSub;

  final OnAudioQuery _audioQuery = OnAudioQuery();

  AudioPlayerController() {
    _init();
  }

  // ---------------------------------------------------------
  // INIT
  // ---------------------------------------------------------
  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {}

    _artDir = await _getArtDirectory();

    // Track index updates
    _indexSub = player.currentIndexStream.listen((index) {
      if (index == null) return;
      currentIndex = index;
      notifyListeners();
    });

    // Play/pause updates
    _isPlaying = player.playing;
    _playingSub = player.playingStream.listen((playing) {
      if (playing == _isPlaying) return;
      _isPlaying = playing;
      notifyListeners();
    });
  }

  // ---------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------
  SongModel? get currentSong {
    if (playlist.isEmpty) return null;
    if (currentIndex < 0 || currentIndex >= playlist.length) {
      currentIndex = 0;
    }
    return playlist[currentIndex];
  }

  int? get currentSongId => currentSong?.id;

  bool get isPlaying => _isPlaying;

  Stream<bool> get playingStream => player.playingStream;

  // ---------------------------------------------------------
  // POSITION STREAM (throttled)
  // ---------------------------------------------------------
  StreamTransformer<T, T> _throttle<T>(Duration duration) {
    return StreamTransformer<T, T>.fromBind((stream) {
      bool canEmit = true;

      return stream.where((event) {
        if (!canEmit) return false;

        canEmit = false;
        Future.delayed(duration, () => canEmit = true);

        return true;
      });
    });
  }

  Stream<PositionData>? _throttledPositionStream;

  Stream<PositionData> get smoothPositionStream {
    _ensurePositionStream();

    _throttledPositionStream ??= _posCtrl!
        .stream
        .transform(_throttle(const Duration(milliseconds: 120)))
        .asBroadcastStream();

    return _throttledPositionStream!;
  }

  // Raw position stream
  Stream<PositionData> get positionDataStream {
    _ensurePositionStream();
    return _posCtrl!.stream;
  }

  void _ensurePositionStream() {
    if (_posCtrl != null) return;

    _posCtrl = StreamController<PositionData>.broadcast();

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
    if (_posCtrl == null || _posCtrl!.isClosed) return;

    _posCtrl!.add(
      PositionData(
        position: _pos,
        bufferedPosition: _buff,
        duration: _dur,
      ),
    );
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

  Uri? getCachedArtworkUri(int id) => _artCache[id];

  final Map<int, Future<Uri?>> _artFetchFutures = {};

  Future<Uri?> ensureArtworkForId(int songId) async {
    if (_artCache.containsKey(songId)) return _artCache[songId];

    if (_artFetchFutures.containsKey(songId)) {
      return await _artFetchFutures[songId];
    }

    final completer = Completer<Uri?>();
    _artFetchFutures[songId] = completer.future;

    try {
      _artDir ??= await _getArtDirectory();
      final file = File(p.join(_artDir!.path, '${songId}_art.jpg'));
      if (await file.exists()) {
        final uri = Uri.file(file.path);
        _artCache[songId] = uri;
        completer.complete(uri);
        return uri;
      }

      final bytes = await _audioQuery.queryArtwork(songId, ArtworkType.AUDIO);
      if (bytes == null || bytes.isEmpty) {
        _artCache[songId] = null;
        completer.complete(null);
        return null;
      }

      await file.writeAsBytes(bytes, flush: true);
      final uri = Uri.file(file.path);
      _artCache[songId] = uri;
      completer.complete(uri);
      return uri;
    } catch (_) {
      _artCache[songId] = null;
      completer.complete(null);
      return null;
    } finally {
      _artFetchFutures.remove(songId);
    }
  }

  Future<void> preloadArtworkForQueue() async {
    if (playlist.isEmpty) return;

    final futures = <Future<Uri?>>[];

    for (final song in playlist) {
      if (!_artCache.containsKey(song.id)) {
        futures.add(ensureArtworkForId(song.id));
      }
    }

    // Load everything in background, then refresh UI
    Future.wait(futures).then((_) {
      notifyListeners();
    });
  }

  // ---------------------------------------------------------
  // PLAYLIST SETTER
  // ---------------------------------------------------------
  Future<void> setPlaylist(
    List<SongModel> songs, {
    int initialIndex = 0,
  }) async {
    if (songs.isEmpty) return;

    final safeIndex = initialIndex.clamp(0, songs.length - 1);

    // If same playlist → just jump
    if (_samePlaylistById(playlist, songs)) {
      _rebuildIdLookup(songs);
      await playIndex(safeIndex);
      return;
    }

    playlist = List<SongModel>.from(songs);
    _rebuildIdLookup(playlist);

    // Preload artwork in parallel
    final futures = <Future<Uri?>>[];
    for (final song in playlist) {
      futures.add(ensureArtworkForId(song.id));
    }

    final artUris = await Future.wait(futures);

    final sources = <AudioSource>[];

    for (int i = 0; i < playlist.length; i++) {
      final song = playlist[i];
      final artUri = artUris[i];

      final media = MediaItem(
        id: song.id.toString(),
        title: song.title,
        album: song.album ?? '',
        artist: song.artist ?? '',
        artUri: artUri,
        extras: {'uri': song.data},
      );

      sources.add(
        AudioSource.uri(
          Uri.file(song.data),
          tag: media,
        ),
      );
    }

    await player.setAudioSources(
      sources,
      initialIndex: safeIndex,
      initialPosition: Duration.zero,
    );

    currentIndex = safeIndex;
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
    for (int i = 0; i < list.length; i++) {
      _idToIndex[list[i].id] = i;
    }
  }

  // ---------------------------------------------------------
  // PLAYBACK CONTROL
  // ---------------------------------------------------------
  Future<void> playIndex(int index) async {
    if (index < 0 || index >= playlist.length) return;

    currentIndex = index;
    await player.seek(Duration.zero, index: index);
    await player.play();
  }

  Future<void> playSong(SongModel song) async {
    final idx = _idToIndex[song.id];
    if (idx != null) {
      await playIndex(idx);
    }
  }

  void togglePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void next() => player.seekToNext();
  void previous() => player.seekToPrevious();

  Future<void> seek(Duration pos) async {
    await player.seek(pos);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final s = speed.clamp(0.25, 3.0);
    try {
      await player.setSpeed(s);
    } catch (_) {}
  }

  Future<void> toggleShuffle() async {
    isShuffling = !isShuffling;
    await player.setShuffleModeEnabled(isShuffling);
    if (isShuffling) {
      await player.shuffle();
    }
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
    _playingSub?.cancel();
    _posCtrl?.close();
    player.dispose();
    super.dispose();
  }
}
