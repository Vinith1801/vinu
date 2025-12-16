import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vinu/ui/shared/artwork_loader.dart';

class TrackTile extends StatelessWidget {
  final String title;
  final String artist;
  final int songId;

  final bool isFavorite;

  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToPlaylist;
  final VoidCallback? onRemoveFromPlaylist;

  const TrackTile({
    super.key,
    required this.title,
    required this.artist,
    required this.songId,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    this.onRemoveFromPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _buildArtwork(scheme),
            const SizedBox(width: 14),
            _buildText(scheme),
            _buildMenu(scheme),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(ColorScheme scheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 55,
        height: 55,
        child: ArtworkLoader(
          id: songId,
          type: ArtworkType.AUDIO,
          size: 55,
          borderRadius: BorderRadius.circular(8),
          placeholder: Container(
            color: scheme.surfaceContainerHighest,
            child: Icon(
              Icons.music_note,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(ColorScheme scheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(ColorScheme scheme) {
    return PopupMenuButton<_TrackAction>(
      icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
      onSelected: _handleAction,
      itemBuilder: (_) {
        final items = <PopupMenuEntry<_TrackAction>>[
          PopupMenuItem(
            value: _TrackAction.favorite,
            child: Text(
              isFavorite
                  ? 'Remove from Favorites'
                  : 'Add to Favorites',
            ),
          ),
          const PopupMenuItem(
            value: _TrackAction.addToPlaylist,
            child: Text('Add to Playlist'),
          ),
        ];

        if (onRemoveFromPlaylist != null) {
          items.add(
            const PopupMenuItem(
              value: _TrackAction.removeFromPlaylist,
              child: Text('Remove from this Playlist'),
            ),
          );
        }

        return items;
      },
    );
  }

  void _handleAction(_TrackAction action) {
    switch (action) {
      case _TrackAction.favorite:
        onToggleFavorite();
        break;
      case _TrackAction.addToPlaylist:
        onAddToPlaylist();
        break;
      case _TrackAction.removeFromPlaylist:
        onRemoveFromPlaylist?.call();
        break;
    }
  }
}

enum _TrackAction {
  favorite,
  addToPlaylist,
  removeFromPlaylist,
}
