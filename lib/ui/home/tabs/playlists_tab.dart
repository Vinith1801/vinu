import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/state/playlist/playlist_controller.dart';
import 'package:vinu/state/playlist/vinu_playlist.dart';


import '../../playlist/playlist_dialogs.dart';
import '../../playlist/playlist_songs_screen.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistCtrl = context.watch<PlaylistController>();
    final playlists = playlistCtrl.playlists;

    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.6);

    return Column(
      children: [
        const SizedBox(height: 12),

        // CREATE PLAYLIST CARD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _CreatePlaylistCard(
            onTap: () => PlaylistDialogs.showCreate(context),
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: playlists.isEmpty
              ? _EmptyPlaylistsState(muted: muted)
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: playlists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = playlists[i];
                    return _PlaylistTile(playlist: p);
                  },
                ),
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              CREATE PLAYLIST                               */
/* -------------------------------------------------------------------------- */

class _CreatePlaylistCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePlaylistCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add_rounded,
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Create playlist',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               PLAYLIST TILE                                */
/* -------------------------------------------------------------------------- */

class _PlaylistTile extends StatelessWidget {
  final VinuPlaylist playlist;

  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ctrl = context.read<PlaylistController>();

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.queue_music_rounded,
          color: scheme.primary,
        ),
      ),
      title: Text(
        playlist.name,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      subtitle: Text(
        '${playlist.songIds.length} songs',
        style: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          if (v == 'rename') {
            _showRenameDialog(context, playlist);
          } else if (v == 'delete') {
            final confirmed = await _confirmDelete(context, playlist);
            if (confirmed) {
              ctrl.deletePlaylist(playlist.id);
            }
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'rename', child: Text('Rename')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaylistSongsScreen(playlist: playlist),
          ),
        );
      },
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                EMPTY STATE                                 */
/* -------------------------------------------------------------------------- */

class _EmptyPlaylistsState extends StatelessWidget {
  final Color muted;

  const _EmptyPlaylistsState({required this.muted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_music_rounded, size: 64, color: muted),
          const SizedBox(height: 12),
          Text('No playlists yet', style: TextStyle(color: muted)),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                DIALOG HELPERS                               */
/* -------------------------------------------------------------------------- */

void _showRenameDialog(BuildContext ctx, VinuPlaylist p) {
  final tc = TextEditingController(text: p.name);

  showDialog(
    context: ctx,
    builder: (_) {
      return AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: tc,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = tc.text.trim();
              if (newName.isNotEmpty) {
                ctx
                    .read<PlaylistController>()
                    .renamePlaylist(p.id, newName);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<bool> _confirmDelete(BuildContext ctx, VinuPlaylist p) async {
  final res = await showDialog<bool>(
    context: ctx,
    builder: (_) {
      return AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text(
          "Delete '${p.name}'? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return res == true;
}
