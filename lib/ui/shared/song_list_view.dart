import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/player/library_view_controller.dart';
import 'package:vinu/ui/shared/song_grid_tile.dart';

import 'track_tile.dart';

class SongListView extends StatelessWidget {
  final List<SongModel> songs;
  final void Function(int index) onPlay;
  final void Function(int songId) onToggleFavorite;
  final void Function(int songId) onAddToPlaylist;
  final bool Function(int songId) isFavorite;
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
    if (songs.isEmpty) return const SizedBox.shrink();

    final view = context.watch<LibraryViewController>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: view.viewMode == LibraryViewMode.list
          ? _buildList(context)
          : _buildGrid(context, view.gridCount),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('list'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: songs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _tile(context, i),
    );
  }

  Widget _buildGrid(BuildContext context, int count) {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.all(12),
      itemCount: songs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85, // FIXED
      ),
      itemBuilder: (_, i) {
        final s = songs[i];

        return SongGridTile(
          songId: s.id,
          title: s.title,
          isFavorite: isFavorite(s.id),
          onTap: () => onPlay(i),
          onToggleFavorite: () => onToggleFavorite(s.id),
          onAddToPlaylist: () => onAddToPlaylist(s.id),
          onRemoveFromPlaylist: onRemoveFromPlaylist == null
              ? null
              : () => onRemoveFromPlaylist!(s.id),
        );
      },
    );
  }

  Widget _tile(BuildContext context, int i) {
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
          onRemoveFromPlaylist == null ? null : () => onRemoveFromPlaylist!(s.id),
    );
  }
}
