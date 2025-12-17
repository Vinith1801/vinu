import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'artwork_loader.dart';

class SongGridTile extends StatelessWidget {
  final int songId;
  final String title;
  final bool isFavorite;

  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToPlaylist;
  final VoidCallback? onRemoveFromPlaylist;

  const SongGridTile({
    super.key,
    required this.songId,
    required this.title,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ARTWORK (square, locked)
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ArtworkLoader(
                id: songId,
                type: ArtworkType.AUDIO,
                size: 300,
                borderRadius: BorderRadius.zero,
                placeholder: Container(
                  color: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.music_note,
                    size: 36,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // TITLE + MENU (height controlled)
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              PopupMenuButton<_GridAction>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                onSelected: (action) {
                  switch (action) {
                    case _GridAction.favorite:
                      onToggleFavorite();
                      break;
                    case _GridAction.addToPlaylist:
                      onAddToPlaylist();
                      break;
                    case _GridAction.removeFromPlaylist:
                      onRemoveFromPlaylist?.call();
                      break;
                  }
                },
                itemBuilder: (_) {
                  final items = <PopupMenuEntry<_GridAction>>[
                    PopupMenuItem(
                      value: _GridAction.favorite,
                      child: Text(
                        isFavorite
                            ? 'Remove from Favorites'
                            : 'Add to Favorites',
                      ),
                    ),
                    const PopupMenuItem(
                      value: _GridAction.addToPlaylist,
                      child: Text('Add to Playlist'),
                    ),
                  ];

                  if (onRemoveFromPlaylist != null) {
                    items.add(
                      const PopupMenuItem(
                        value: _GridAction.removeFromPlaylist,
                        child: Text('Remove from this Playlist'),
                      ),
                    );
                  }

                  return items;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _GridAction {
  favorite,
  addToPlaylist,
  removeFromPlaylist,
}
