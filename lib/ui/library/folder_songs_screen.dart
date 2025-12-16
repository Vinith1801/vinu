import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/player/favorites_controller.dart';
import 'package:vinu/ui/playlist/add_to_playlist_sheet.dart';

import '../../player/library_controller.dart';
import '../../player/audio_player_controller.dart';
import '../shared/track_tile.dart';

class FolderSongsScreen extends StatelessWidget {
  final String folderPath;

  const FolderSongsScreen({super.key, required this.folderPath});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final lib = context.watch<LibraryController>();
    final controller = context.read<AudioPlayerController>();
    final fav = context.watch<FavoritesController>();

    // Direct pull from centralized library
    final folderSongs = lib.getSongsByFolder(folderPath);
    final folderName = folderPath.split("/").last;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        title: Text(
          folderName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: scheme.onSurface),
        ),
      ),

      body: folderSongs.isEmpty
          ? Center(child: Text("No songs found", style: TextStyle(color: scheme.onSurfaceVariant)))
          : Column(
              children: [
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        controller.setPlaylist(folderSongs, initialIndex: 0);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 28, color: scheme.onPrimary),
                          const SizedBox(width: 8),
                          Text(
                            "Play All",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: folderSongs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final s = folderSongs[i];
                      return TrackTile(
                        title: s.title,
                        artist: s.artist ?? "Unknown Artist",
                        songId: s.id,
                        isFavorite: fav.isFavorite(s.id),
                        onTap: () => controller.setPlaylist(folderSongs, initialIndex: i),
                        onToggleFavorite: () => fav.toggleFavorite(s.id),
                        onAddToPlaylist: () => AddToPlaylistSheet.show(context, s.id),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
