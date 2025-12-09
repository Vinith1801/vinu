// lib/ui/screens/home/tabs/favorites_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../../player/audio_player_controller.dart';
import '../../../../player/favorites_controller.dart';
import '../../../widgets/track_tile.dart';
import '../../../widgets/song_toolbar.dart';

class FavoritesTab extends StatefulWidget {
  final List<SongModel> songs;

  const FavoritesTab({super.key, required this.songs});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  SongSortMode sortMode = SongSortMode.title;

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesController>();
    final controller = context.read<AudioPlayerController>();
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withAlpha((0.5 * 255).toInt());

    final favSongs = widget.songs.where((s) => fav.isFavorite(s.id)).toList();

    if (favSongs.isEmpty) {
      return Center(child: Text("No favorites yet ❤️", style: TextStyle(color: muted)));
    }

    // Copy + sort
    final List<SongModel> list = List<SongModel>.from(favSongs);
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
