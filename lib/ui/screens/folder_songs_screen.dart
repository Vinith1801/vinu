//lib/ui/screens/folder_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/audio_player_controller.dart';
import '../widgets/track_tile.dart';

class FolderSongsScreen extends StatefulWidget {
  final String folderPath;

  const FolderSongsScreen({super.key, required this.folderPath});

  @override
  State<FolderSongsScreen> createState() => _FolderSongsScreenState();
}

class _FolderSongsScreenState extends State<FolderSongsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> folderSongs = [];

  @override
  void initState() {
    super.initState();
    loadSongsFromFolder();
  }

  Future<void> loadSongsFromFolder() async {
    final allSongs = await _audioQuery.querySongs();

    folderSongs = allSongs
        .where((s) => s.data.startsWith(widget.folderPath))
        .toList();

    folderSongs.sort((a, b) => a.title.compareTo(b.title));

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = context.read<AudioPlayerController>();

    final folderName = widget.folderPath.split("/").last;

    return Scaffold(
      backgroundColor: scheme.surface,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        title: Text(
          folderName,
          style: TextStyle(
            fontSize: 20,
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: folderSongs.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: scheme.primary,
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 10),

                // -----------------------------------------
                // PLAY ALL BUTTON (Dynamic Accent)
                // -----------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: scheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        controller.setPlaylist(folderSongs);
                        controller.playIndex(0);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            size: 28,
                            color: scheme.onPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Play All",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // -----------------------------------------
                // SONG LIST
                // -----------------------------------------
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: folderSongs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final s = folderSongs[i];

                      return TrackTile(
                        title: s.title,
                        artist: s.artist ?? "Unknown Artist",
                        songId: s.id,
                        onTap: () {
                          controller.setPlaylist(folderSongs);
                          controller.playIndex(i);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
