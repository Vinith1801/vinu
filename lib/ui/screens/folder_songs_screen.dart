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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderPath.split("/").last),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: folderSongs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // PLAY ALL BUTTON
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.play_circle_fill, size: 28),
                    label: const Text(
                      "Play All",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      controller.setPlaylist(folderSongs);
                      controller.playSong(folderSongs.first);
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // SONG LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: folderSongs.length,
                    itemBuilder: (_, i) {
                      final s = folderSongs[i];
                      return TrackTile(
                        title: s.title,
                        artist: s.artist ?? "Unknown Artist",
                        songId: s.id,
                        onTap: () {
                          controller.setPlaylist(folderSongs);
                          controller.playSong(s);
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
