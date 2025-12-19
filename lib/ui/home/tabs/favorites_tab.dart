import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vinu/state/player/audio_player_controller.dart';
import 'package:vinu/ui/playlist/add_to_playlist_sheet.dart';
import 'package:vinu/ui/shared/song_sort_mode.dart';
import 'package:vinu/ui/shared/song_sorter.dart';

import '../../../state/favorites/favorites_controller.dart';
import '../../shared/track_tile.dart';
import '../../shared/song_toolbar.dart';

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

    final favSongs = widget.songs
        .where((s) => fav.isFavorite(s.id))
        .toList();

    if (favSongs.isEmpty) {
      return Center(
        child: Text(
          "No favorites yet ❤️",
          style: TextStyle(color: muted),
        ),
      );
    }

    final list = SongSorter.sort(favSongs, sortMode);

    return Column(
      children: [
        SongToolbar(
          activeSort: sortMode,
          onShuffle: () {
            final shuffled = List<SongModel>.from(list)..shuffle();
            controller.queue.setPlaylist(shuffled, index: 0);
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
                title: s.title,
                artist: s.artist ?? "Unknown",
                songId: s.id,
                isFavorite: fav.isFavorite(s.id),
                onTap: () => controller.queue.setPlaylist(list, index: i),
                onToggleFavorite: () => fav.toggleFavorite(s.id),
                onAddToPlaylist: () => AddToPlaylistSheet.show(context, s.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
