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

    folderSongs = allSongs.where((s) {
      // More accurate folder detection
      return s.data.startsWith(widget.folderPath);
    }).toList();

    folderSongs.sort((a, b) => a.title.compareTo(b.title));

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AudioPlayerController>();
    final folderName = widget.folderPath.split("/").last;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Text(
          folderName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: folderSongs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),

                // PLAY ALL BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.black,
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
                        children: const [
                          Icon(Icons.play_arrow_rounded, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "Play All",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SONG LIST (NO EXTRA CARDS)
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
