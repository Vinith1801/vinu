// lib/ui/screens/home/tabs/playlists_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/models/vinu_playlist.dart';
import 'package:vinu/player/playlist_controller.dart';

import '../../playlist_songs_screen.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistCtrl = context.watch<PlaylistController>();
    final playlists = playlistCtrl.playlists;
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.6);

    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.playlist_add_rounded),
            label: const Text("Create Playlist"),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => _showCreateDialog(context),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: playlists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.queue_music_rounded, size: 64, color: muted),
                      const SizedBox(height: 12),
                      Text("No playlists yet", style: TextStyle(color: muted)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: playlists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = playlists[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.queue_music_rounded, color: scheme.primary),
                      ),
                      title: Text(p.name, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
                      subtitle: Text("${p.songIds.length} songs", style: TextStyle(color: scheme.onSurface.withOpacity(0.6))),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'rename') {
                            _showRenameDialog(context, p);
                          } else if (v == 'delete') {
                            final confirmed = await _confirmDelete(context, p);
                            if (confirmed) {
                              context.read<PlaylistController>().deletePlaylist(p.id);
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'rename', child: Text("Rename")),
                          PopupMenuItem(value: 'delete', child: Text("Delete")),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlaylistSongsScreen(playlist: p)),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext ctx) {
    final tc = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          title: const Text("New Playlist"),
          content: TextField(
            controller: tc,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Playlist name"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                final name = tc.text.trim();
                if (name.isNotEmpty) {
                  ctx.read<PlaylistController>().createPlaylist(name);
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _showRenameDialog(BuildContext ctx, VinuPlaylist p) {
    final tc = TextEditingController(text: p.name);
    showDialog(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          title: const Text("Rename Playlist"),
          content: TextField(controller: tc, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                final newName = tc.text.trim();
                if (newName.isNotEmpty) {
                  ctx.read<PlaylistController>().renamePlaylist(p.id, newName);
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Save"),
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
          title: const Text("Delete Playlist"),
          content: Text("Delete '${p.name}'? This cannot be undone."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
          ],
        );
      },
    );
    return res == true;
  }
}
