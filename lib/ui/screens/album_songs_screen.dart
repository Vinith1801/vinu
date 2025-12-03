// lib/ui/screens/album_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../player/audio_player_controller.dart';
import '../../player/library_controller.dart';
import '../widgets/track_tile.dart';

class AlbumSongsScreen extends StatelessWidget {
  final AlbumModel album;

  const AlbumSongsScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final lib = context.watch<LibraryController>();
    final controller = context.read<AudioPlayerController>();

    // Pull filtered list directly from the centralized library
    final songs = lib.getSongsByAlbum(album.id);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: Text(
          album.album,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),

      body: songs.isEmpty
          ? Center(
              child: Text(
                "No songs found",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 14),

                // Album artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: QueryArtworkWidget(
                    id: album.id,
                    type: ArtworkType.ALBUM,
                    artworkHeight: 160,
                    artworkWidth: 160,
                    nullArtworkWidget: Container(
                      height: 160,
                      width: 160,
                      color: scheme.surfaceContainerHighest,
                      child: Icon(Icons.album, size: 48, color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  album.album,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  "${songs.length} Songs",
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: songs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final s = songs[i];
                      return TrackTile(
                        title: s.title,
                        artist: s.artist ?? "Unknown Artist",
                        songId: s.id,
                        onTap: () {
                          controller.setPlaylist(songs, initialIndex: i);
                        },
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
