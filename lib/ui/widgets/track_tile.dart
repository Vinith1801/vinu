// lib/ui/widgets/track_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vinu/player/playlist_controller.dart';
import 'package:vinu/ui/widgets/artwork_loader.dart';

import '../../player/favorites_controller.dart';

class TrackTile extends StatelessWidget {
  final String title;
  final String artist;
  final int songId;
  final VoidCallback onTap;

  // NEW: tells the tile/menu whether it's inside a playlist screen
  final bool insidePlaylist;
  final String? playlistId;

  const TrackTile({
    super.key,
    required this.title,
    required this.artist,
    required this.songId,
    required this.onTap,
    this.insidePlaylist = false,
    this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Artwork (unified)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 55,
                    height: 55,
                    child: RepaintBoundary(
                      child: ArtworkLoader(
                        id: songId,
                        type: ArtworkType.AUDIO,
                        size: 55,
                        borderRadius: BorderRadius.circular(8),
                        placeholder: Container(
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
                  ),
                ),

                const SizedBox(width: 14),

                // Title + Artist
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

                _PopupMenu(
                  songId: songId,
                  title: title,
                  artist: artist,
                  insidePlaylist: insidePlaylist,
                  playlistId: playlistId,
                ),
              ],
            ),
          ),
        ),

        const Divider(
          height: 1,
          thickness: 0.6,
        ),
      ],
    );
  }
}

// ------------------ POPUP MENU remains unchanged ------------------

class _PopupMenu extends StatelessWidget {
  final int songId;
  final String title;
  final String artist;
  final bool insidePlaylist;
  final String? playlistId;

  const _PopupMenu({
    required this.songId,
    required this.title,
    required this.artist,
    this.insidePlaylist = false,
    this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesController>();
    final isFav = fav.isFavorite(songId);
    final scheme = Theme.of(context).colorScheme;
    final playlistCtrl = context.read<PlaylistController>();

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
      onSelected: (value) async {
        switch (value) {
          case 'fav':
            fav.toggleFavorite(songId);
            break;
          case 'addPlaylist':
            _openAddToPlaylist(context, songId);
            break;
          case 'removePlaylist':
            if (insidePlaylist && playlistId != null) {
              playlistCtrl.removeSong(playlistId!, songId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Removed from playlist')),
              );
            }
            break;
          case 'share':
            // implement share if you add share_plus
            break;
          case 'delete':
            // optional: delete file (requires permission & caution)
            break;
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'fav',
          child: Text(isFav ? 'Remove from Favorites' : 'Add to Favorites'),
        ),
        const PopupMenuItem(
          value: 'addPlaylist',
          child: Text('Add to Playlist'),
        ),
        if (insidePlaylist)
          const PopupMenuItem(
            value: 'removePlaylist',
            child: Text('Remove from this Playlist'),
          ),
        const PopupMenuItem(
          value: 'share',
          child: Text('Share'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    );
  }

  void _openAddToPlaylist(BuildContext ctx, int songId) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Add to Playlist",
                    style: Theme.of(ctx)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (_, i) {
                    final p = playlists[i];
                    final exists = p.songIds.contains(songId);

                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text("${p.songIds.length} songs"),
                      trailing: exists ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () {
                        if (!exists) {
                          ctx.read<PlaylistController>().addSong(p.id, songId);
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
              if (playlists.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No playlists yet. Create one from Playlists tab.',
                      style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                ),
            ],
          ),
        );
      },
    );
  }
}
