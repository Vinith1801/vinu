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

    _indexSub = player.currentIndexStream.listen((index) {
      if (index == null) return;
      currentIndex = index;
      notifyListeners();
    });
  }

  // ---------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------
  SongModel? get currentSong =>
      playlist.isEmpty ? null : playlist[currentIndex];

  int? get currentSongId => currentSong?.id;
  bool get isPlaying => player.playing;

  Stream<bool> get playingStream => player.playingStream;

  // ---------------------------------------------------------
  // POSITION STREAM
  // ---------------------------------------------------------
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

  Future<Uri?> ensureArtworkForId(int songId) async {
    if (_artCache.containsKey(songId)) {
      return _artCache[songId];
    }

    _artDir ??= await _getArtDirectory();
    final file = File(p.join(_artDir!.path, '${songId}_art.jpg'));

    if (await file.exists()) {
      final uri = Uri.file(file.path);
      _artCache[songId] = uri;
      return uri;
    }

    try {
      final bytes = await _audioQuery.queryArtwork(songId, ArtworkType.AUDIO);
      if (bytes == null) {
        _artCache[songId] = null;
        return null;
      }

      await file.writeAsBytes(bytes, flush: true);
      final uri = Uri.file(file.path);
      _artCache[songId] = uri;
      return uri;
    } catch (_) {
      _artCache[songId] = null;
      return null;
    }
  }

  // ---------------------------------------------------------
  // PLAYLIST SETTER — ***FAST, NON-BLOCKING VERSION***
  // ---------------------------------------------------------
  Future<void> setPlaylist(
    List<SongModel> songs, {
    int initialIndex = 0,
  }) async {
    if (songs.isEmpty) return;

    // Fast path
    if (_samePlaylistById(playlist, songs)) {
      _rebuildIdLookup(songs);
      await playIndex(initialIndex);
      return;
    }

    playlist = List<SongModel>.from(songs);
    _rebuildIdLookup(playlist);

    final sources = <AudioSource>[];

    // Only use cached artwork here — DO NOT await artwork
    for (final song in playlist) {
      final artUri = await ensureArtworkForId(song.id);

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

    // Instantly set playlist & start playback — NO WAITING
    await player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );

    currentIndex = initialIndex;
    notifyListeners();
    await player.play();

    // Background artwork population (non-blocking)
    unawaited(_populateArtworkCache(playlist));
  }

  Future<void> _populateArtworkCache(List<SongModel> list) async {
    for (final s in list) {
      if (_artCache.containsKey(s.id)) continue;
      try {
        await ensureArtworkForId(s.id);
      } catch (_) {}
    }
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
    _posCtrl?.close();
    player.dispose();
    super.dispose();
  }
}
