import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/favorites_controller.dart';

class TrackTile extends StatelessWidget {
  final String title;
  final String artist;
  final int songId;
  final VoidCallback onTap;

  const TrackTile({
    super.key,
    required this.title,
    required this.artist,
    required this.songId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesController>();
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // --------------------
            // Artwork
            // --------------------
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: QueryArtworkWidget(
                id: songId,
                type: ArtworkType.AUDIO,
                artworkHeight: 55,
                artworkWidth: 55,
                nullArtworkWidget: Container(
                  height: 55,
                  width: 55,
                  color: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.music_note,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // --------------------
            // Title + Artist
            // --------------------
            Expanded(
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
            ),

            const SizedBox(width: 10),

            // --------------------
            // Favorite button
            // --------------------
            GestureDetector(
              onTap: () => fav.toggleFavorite(songId),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  fav.isFavorite(songId)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(fav.isFavorite(songId)),
                  color: fav.isFavorite(songId)
                      ? scheme.primary
                      : scheme.onSurfaceVariant.withValues(alpha: 0.06),
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
