import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/audio_player_controller.dart';
import '../widgets/header.dart';
import '../widgets/track_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    bool permission = await _audioQuery.permissionsStatus();
    if (!permission) permission = await _audioQuery.permissionsRequest();
    if (!permission) return;

    songs = await _audioQuery.querySongs();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AudioPlayerController>(context);

    return SafeArea(
      child: Column(
        children: [
          const Header(),

          Expanded(
            child: songs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, i) {
                      return TrackTile(
                        title: songs[i].title,
                        artist: songs[i].artist ?? "Unknown",
                        songId: songs[i].id,
                        onTap: () {
                          controller.setPlaylist(songs);
                          controller.playSong(songs[i]);
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
