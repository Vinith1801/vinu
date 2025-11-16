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
    final fav = Provider.of<FavoritesController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ======================
            // ARTWORK
            // ======================
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: QueryArtworkWidget(
                id: songId,
                type: ArtworkType.AUDIO,
                artworkHeight: 55,
                artworkWidth: 55,
                nullArtworkWidget: Container(
                  width: 55,
                  height: 55,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.music_note, color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ======================
            // TEXT INFO
            // ======================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // ARTIST
                  Text(
                    artist,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ======================
            // FAVORITE BUTTON
            // ======================
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
                  color: fav.isFavorite(songId) ? Colors.red : Colors.grey,
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
