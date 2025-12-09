import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum SongSortMode { title, artist, duration, date }

class SongToolbar extends StatelessWidget {
  final List<SongModel> songs;
  final VoidCallback onShuffle;
  final ValueChanged<SongSortMode> onSort;

  final SongSortMode activeSort;

  const SongToolbar({
    super.key,
    required this.songs,
    required this.onShuffle,
    required this.onSort,
    required this.activeSort,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          // SHUFFLE BUTTON
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onShuffle,
            icon: const Icon(Icons.shuffle_rounded, size: 22),
            label: const Text(
              "Shuffle",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          const Spacer(),

          // SORT MENU
          PopupMenuButton<SongSortMode>(
            tooltip: "Sort",
            icon: Icon(Icons.sort_rounded, color: scheme.onSurface),
            onSelected: onSort,
            itemBuilder: (_) => [
              _sortItem(SongSortMode.title, "Title"),
              _sortItem(SongSortMode.artist, "Artist"),
              _sortItem(SongSortMode.duration, "Duration"),
              _sortItem(SongSortMode.date, "Recently Added"),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<SongSortMode> _sortItem(SongSortMode mode, String label) {
    return PopupMenuItem(
      value: mode,
      child: Text(label),
    );
  }
}
