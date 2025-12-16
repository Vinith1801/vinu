import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/models/vinu_playlist.dart';
import 'package:vinu/player/playlist_controller.dart';

class PlaylistDialogs {
  static void showCreate(BuildContext ctx) {
    final tc = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
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
      ),
    );
  }

  static void showRename(BuildContext ctx, VinuPlaylist p) {
    final tc = TextEditingController(text: p.name);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
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
      ),
    );
  }

  static Future<bool> confirmDelete(BuildContext ctx, VinuPlaylist p) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Delete Playlist"),
        content: Text("Delete '${p.name}'? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );
    return res == true;
  }
}
