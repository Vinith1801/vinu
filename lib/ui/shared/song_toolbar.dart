import 'package:flutter/material.dart';
import 'song_sort_mode.dart';

class SongToolbar extends StatelessWidget {
  final VoidCallback onShuffle;
  final ValueChanged<SongSortMode> onSort;
  final SongSortMode activeSort;

  const SongToolbar({
    super.key,
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
          // SHUFFLE
          ElevatedButton.icon(
            onPressed: onShuffle,
            icon: const Icon(Icons.shuffle_rounded, size: 22),
            label: const Text(
              "Shuffle",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const Spacer(),

          // SORT
          PopupMenuButton<SongSortMode>(
            tooltip: "Sort",
            icon: Icon(Icons.sort_rounded, color: scheme.onSurface),
            onSelected: onSort,
            itemBuilder: (_) => [
              _sortItem(context, SongSortMode.title, "Title"),
              _sortItem(context, SongSortMode.artist, "Artist"),
              _sortItem(context, SongSortMode.duration, "Duration"),
              _sortItem(context, SongSortMode.date, "Recently Added"),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<SongSortMode> _sortItem(
    BuildContext context,
    SongSortMode mode,
    String label,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = mode == activeSort;

    return PopupMenuItem<SongSortMode>(
      value: mode,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          if (isActive)
            Icon(
              Icons.check,
              size: 18,
              color: scheme.primary,
            ),
        ],
      ),
    );
  }
}
