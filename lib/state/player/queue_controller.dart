import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../core/audio/audio_engine.dart';
import 'artwork_controller.dart';

class QueueController extends ChangeNotifier {
  final AudioEngine engine;
  final ArtworkController artwork;

  List<SongModel> playlist = [];
  final Map<int, int> _idIndex = {};
  int currentIndex = 0;

  QueueController(this.engine, this.artwork) {
    engine.player.currentIndexStream.listen((i) {
      if (i != null) {
        currentIndex = i;
        notifyListeners();
      }
    });
  }

  SongModel? get currentSong =>
      playlist.isEmpty ? null : playlist[currentIndex];

  Future<void> setPlaylist(List<SongModel> songs, {int index = 0}) async {
    playlist = List.from(songs);
    _idIndex
      ..clear()
      ..addEntries(
        List.generate(songs.length,
            (i) => MapEntry(songs[i].id, i)),
      );

    final sources = <AudioSource>[];

    for (final s in playlist) {
      final art = await artwork.ensure(s.id);
      sources.add(
        AudioSource.uri(
          Uri.file(s.data),
          tag: MediaItem(
            id: s.id.toString(),
            title: s.title,
            album: s.album ?? '',
            artist: s.artist ?? '',
            artUri: art,
          ),
        ),
      );
    }

    await engine.player.setAudioSources(
      sources,
      initialIndex: index.clamp(0, playlist.length - 1),
    );

    await engine.player.play();
    notifyListeners();
  }

  Future<void> playSong(SongModel s) async {
    final idx = _idIndex[s.id];
    if (idx != null) {
      await engine.player.seek(Duration.zero, index: idx);
      await engine.player.play();
    }
  }
}
