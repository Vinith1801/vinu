// lib/ui/screens/home/tabs/songs_tab.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../../../player/audio_player_controller.dart';
import '../../../widgets/track_tile.dart';

class SongsTab extends StatelessWidget {
  final List<SongModel> songs;

  const SongsTab({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AudioPlayerController>();
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    if (songs.isEmpty) {
      return Center(child: Text("No songs found", style: TextStyle(color: muted)));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: songs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = songs[i];
        return TrackTile(
          title: s.title,
          artist: s.artist ?? "Unknown",
          songId: s.id,
          onTap: () => controller.setPlaylist(songs, initialIndex: i),
        );
      },
    );
  }
}
