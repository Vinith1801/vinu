import 'dart:async';
import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ArtworkController {
  final _query = OnAudioQuery();
  final _cache = <int, Uri?>{};
  final _inFlight = <int, Future<Uri?>>{};
  Directory? _dir;

  Future<Directory> _ensureDir() async {
    _dir ??= Directory(
      p.join((await getApplicationSupportDirectory()).path, 'artwork_cache'),
    )..createSync(recursive: true);
    return _dir!;
  }

  Uri? getCached(int id) => _cache[id];

  Future<Uri?> ensure(int songId) async {
    if (_cache.containsKey(songId)) return _cache[songId];
    if (_inFlight.containsKey(songId)) return _inFlight[songId];

    final f = _load(songId);
    _inFlight[songId] = f;
    final r = await f;
    _inFlight.remove(songId);
    return r;
  }

  Future<Uri?> _load(int songId) async {
    try {
      final dir = await _ensureDir();
      final file = File(p.join(dir.path, '$songId.jpg'));

      if (file.existsSync()) {
        return _cache[songId] = Uri.file(file.path);
      }

      final bytes = await _query.queryArtwork(songId, ArtworkType.AUDIO);
      if (bytes == null || bytes.isEmpty) return _cache[songId] = null;

      await file.writeAsBytes(bytes, flush: true);
      return _cache[songId] = Uri.file(file.path);
    } catch (_) {
      return _cache[songId] = null;
    }
  }
}
