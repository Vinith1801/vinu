import 'package:on_audio_query/on_audio_query.dart';
import 'package:vinu/ui/shared/song_sort_mode.dart';

class SongSorter {
  static List<SongModel> sort(
    List<SongModel> songs,
    SongSortMode mode,
  ) {
    final list = List<SongModel>.from(songs);

    switch (mode) {
      case SongSortMode.title:
        list.sort(_byTitle);
        break;
      case SongSortMode.artist:
        list.sort(_byArtist);
        break;
      case SongSortMode.duration:
        list.sort(_byDuration);
        break;
      case SongSortMode.date:
        list.sort(_byDateAddedDesc);
        break;
    }

    return list;
  }

  static int _byTitle(SongModel a, SongModel b) =>
      _cmp(a.title, b.title);

  static int _byArtist(SongModel a, SongModel b) =>
      _cmp(a.artist, b.artist);

  static int _byDuration(SongModel a, SongModel b) =>
      (a.duration ?? 0).compareTo(b.duration ?? 0);

  static int _byDateAddedDesc(SongModel a, SongModel b) =>
      (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0);

  static int _cmp(String? a, String? b) {
    final x = (a ?? '').toLowerCase();
    final y = (b ?? '').toLowerCase();
    return x.compareTo(y);
  }
}
