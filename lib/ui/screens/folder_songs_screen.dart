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
      return s.data.contains(widget.folderPath);
    }).toList();

    folderSongs.sort((a, b) => a.title.compareTo(b.title));

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AudioPlayerController>(context);

    final folderName = widget.folderPath.split("/").last;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Text(
          folderName,
          style: const TextStyle(fontSize: 20),
        ),
      ),

      body: folderSongs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),

                // PLAY ALL BUTTON - PREMIUM STYLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text(
                        "Play All",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        controller.setPlaylist(folderSongs);
                        controller.playSong(folderSongs.first);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SONG LIST WITH PREMIUM CARD LOOK
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: folderSongs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final s = folderSongs[i];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: TrackTile(
                          title: s.title,
                          artist: s.artist ?? "Unknown Artist",
                          songId: s.id,
                          onTap: () {
                            controller.setPlaylist(folderSongs);
                            controller.playSong(s);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
