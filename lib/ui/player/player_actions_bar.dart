import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/favorites/favorites_controller.dart';
import '../../state/playlist/playlist_controller.dart';

class PlayerActionsBar extends StatelessWidget {
  final int songId;

  const PlayerActionsBar({super.key, required this.songId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fav = context.watch<FavoritesController>();
    final isFav = fav.isFavorite(songId);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // FAVORITE BUTTON
          IconButton(
            iconSize: 34,
            onPressed: () => fav.toggleFavorite(songId),
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(width: 24),

          // ADD TO PLAYLIST BUTTON
          IconButton(
            iconSize: 30,
            onPressed: () => _openAddToPlaylist(context),
            icon: Icon(
              Icons.playlist_add_rounded,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddToPlaylist(BuildContext ctx) {
    final playlists = ctx.read<PlaylistController>().playlists;

    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (bottomCtx) {
        return SizedBox(
          height: 380,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                "Add to Playlist",
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: playlists.isEmpty
                    ? Center(
                        child: Text(
                          "No playlists yet.\nCreate one first.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(ctx).colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: playlists.length,
                        itemBuilder: (_, i) {
                          final p = playlists[i];
                          final exists = p.songIds.contains(songId);

                          return ListTile(
                            title: Text(p.name),
                            subtitle: Text("${p.songIds.length} songs"),
                            trailing: exists
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () {
                              if (!exists) {
                                ctx
                                    .read<PlaylistController>()
                                    .addSong(p.id, songId);

                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Added to "${p.name}"')),
                                );
                              }
                              Navigator.pop(bottomCtx);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
