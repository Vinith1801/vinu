import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/state/playlist/playlist_controller.dart';

class AddToPlaylistSheet {
  static void show(BuildContext ctx, int songId) {
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
                    ? const Center(child: Text("No playlists yet"))
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
            ],
          ),
        );
      },
    );
  }
}
