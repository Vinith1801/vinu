// lib/ui/screens/home/tabs/favorites_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../../player/audio_player_controller.dart';
import '../../../../player/favorites_controller.dart';
import '../../../widgets/track_tile.dart';

class FavoritesTab extends StatelessWidget {
  final List<SongModel> songs;

  const FavoritesTab({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesController>();
    final controller = context.read<AudioPlayerController>();
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    final favSongs = songs.where((s) => fav.isFavorite(s.id)).toList();

    if (favSongs.isEmpty) {
      return Center(child: Text("No favorites yet ❤️", style: TextStyle(color: muted)));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: favSongs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = favSongs[i];
        return TrackTile(
          title: s.title,
          artist: s.artist ?? "Unknown",
          songId: s.id,
          onTap: () => controller.setPlaylist(favSongs, initialIndex: i),
        );
      },
    );
  }
}
