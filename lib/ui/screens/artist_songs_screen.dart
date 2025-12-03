// lib/ui/screens/artist_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../player/library_controller.dart';
import '../../player/audio_player_controller.dart';
import '../widgets/track_tile.dart';

class ArtistSongsScreen extends StatelessWidget {
  final ArtistModel artist;

  const ArtistSongsScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final lib = context.watch<LibraryController>();
    final controller = context.read<AudioPlayerController>();

    final songs = lib.getSongsByArtist(artist.artist);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        title: Text(
          artist.artist,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),

      body: songs.isEmpty
          ? Center(
              child: Text("No songs found", style: TextStyle(color: scheme.onSurfaceVariant)),
            )
          : Column(
              children: [
                const SizedBox(height: 14),

                CircleAvatar(
                  radius: 48,
                  backgroundColor: scheme.surfaceContainerHighest,
                  child: Icon(Icons.person, size: 46, color: scheme.onSurfaceVariant),
                ),

                const SizedBox(height: 8),
                Text(
                  artist.artist,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),
                Text("${songs.length} Songs", style: TextStyle(color: scheme.onSurfaceVariant)),

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
                        onTap: () => controller.setPlaylist(songs, initialIndex: i),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
