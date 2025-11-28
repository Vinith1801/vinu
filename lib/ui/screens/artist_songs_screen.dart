//lib/ui/screens/artist_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../player/audio_player_controller.dart';
import '../widgets/track_tile.dart';

class ArtistSongsScreen extends StatefulWidget {
  final ArtistModel artist;

  const ArtistSongsScreen({super.key, required this.artist});

  @override
  State<ArtistSongsScreen> createState() => _ArtistSongsScreenState();
}

class _ArtistSongsScreenState extends State<ArtistSongsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> songs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadArtistSongs();
  }

  Future<void> loadArtistSongs() async {
    final all = await _audioQuery.querySongs();
    songs = all
        .where((s) => s.artist?.toLowerCase() == widget.artist.artist.toLowerCase())
        .toList();

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = context.read<AudioPlayerController>();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: Text(
          widget.artist.artist,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),

      body: _loading
          ? Center(child: CircularProgressIndicator(color: scheme.primary))
          : Column(
              children: [
                const SizedBox(height: 14),

                // Artist Header
                CircleAvatar(
                  radius: 48,
                  backgroundColor: scheme.surfaceContainerHighest,
                  child: Icon(Icons.person, size: 46, color: scheme.onSurfaceVariant),
                ),

                const SizedBox(height: 8),
                Text(
                  widget.artist.artist,
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
