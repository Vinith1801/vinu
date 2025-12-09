// lib/ui/screens/home/tabs/songs_tab.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../../../player/audio_player_controller.dart';
import '../../../widgets/track_tile.dart';
import '../../../widgets/song_toolbar.dart';

class SongsTab extends StatefulWidget {
  final List<SongModel> songs;

  const SongsTab({super.key, required this.songs});

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  SongSortMode sortMode = SongSortMode.title;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AudioPlayerController>();
    final scheme = Theme.of(context).colorScheme;

    if (widget.songs.isEmpty) {
      return Center(
        child: Text(
          "No songs found",
          style: TextStyle(
            color: scheme.onSurface.withAlpha((0.5 * 255).toInt()),
            fontSize: 15,
          ),
        ),
      );
    }

    // Work on a copy to avoid mutating original
    final List<SongModel> list = List<SongModel>.from(widget.songs);
    _applySort(list);

    return Column(
      children: [
        SongToolbar(
          songs: list,
          activeSort: sortMode,
          onShuffle: () {
            final shuffled = List<SongModel>.from(list)..shuffle();
            controller.setPlaylist(shuffled, initialIndex: 0);
          },
          onSort: (mode) {
            setState(() => sortMode = mode);
          },
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final s = list[i];

              return TrackTile(
                key: ValueKey(s.id),
                title: s.title,
                artist: s.artist ?? "Unknown",
                songId: s.id,
                onTap: () => controller.setPlaylist(list, initialIndex: i),
              );
            },
          ),
        ),
      ],
    );
  }

  void _applySort(List<SongModel> list) {
    switch (sortMode) {
      case SongSortMode.title:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;

      case SongSortMode.artist:
        list.sort((a, b) =>
            (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase()));
        break;

      case SongSortMode.duration:
        list.sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
        break;

      case SongSortMode.date:
        list.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
    }
  }
}
