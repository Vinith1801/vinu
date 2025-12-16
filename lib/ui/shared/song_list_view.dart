import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'track_tile.dart';

class SongListView extends StatelessWidget {
  final List<SongModel> songs;

  // Required behavior
  final void Function(int index) onPlay;
  final void Function(int songId) onToggleFavorite;
  final void Function(int songId) onAddToPlaylist;
  final bool Function(int songId) isFavorite;

  // Optional playlist behavior
  final void Function(int songId)? onRemoveFromPlaylist;

  const SongListView({
    super.key,
    required this.songs,
    required this.onPlay,
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.onAddToPlaylist,
    this.onRemoveFromPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: songs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = songs[i];

        return TrackTile(
          key: ValueKey(s.id),
          title: s.title,
          artist: s.artist ?? 'Unknown',
          songId: s.id,
          isFavorite: isFavorite(s.id),
          onTap: () => onPlay(i),
          onToggleFavorite: () => onToggleFavorite(s.id),
          onAddToPlaylist: () => onAddToPlaylist(s.id),
          onRemoveFromPlaylist:
              onRemoveFromPlaylist == null
                  ? null
                  : () => onRemoveFromPlaylist!(s.id),
        );
      },
    );
  }
}
