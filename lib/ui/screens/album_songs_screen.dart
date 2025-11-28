//lib/ui/screens/album_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../player/audio_player_controller.dart';
import '../widgets/track_tile.dart';

class AlbumSongsScreen extends StatefulWidget {
  final AlbumModel album;

  const AlbumSongsScreen({super.key, required this.album});

  @override
  State<AlbumSongsScreen> createState() => _AlbumSongsScreenState();
}

class _AlbumSongsScreenState extends State<AlbumSongsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> songs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadAlbumSongs();
  }

  Future<void> loadAlbumSongs() async {
    final all = await _audioQuery.querySongs();
    songs = all
        .where((s) => s.albumId == widget.album.id)
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
          widget.album.album,
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

                // Album Art
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: QueryArtworkWidget(
                    id: widget.album.id,
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
                  widget.album.album,
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
