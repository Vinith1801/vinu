import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/audio_player_controller.dart';
import 'seekbar.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  double collapsedHeight = 70;
  double expandedHeight = 0;
  double currentHeight = 70;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    expandedHeight = MediaQuery.of(context).size.height * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final c = Provider.of<AudioPlayerController>(context);

    if (c.currentSong == null) return const SizedBox.shrink();

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          currentHeight -= details.delta.dy;
          currentHeight = currentHeight.clamp(collapsedHeight, expandedHeight);
        });
      },
      onVerticalDragEnd: (_) {
        currentHeight > expandedHeight / 2
            ? currentHeight = expandedHeight
            : currentHeight = collapsedHeight;
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: currentHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10),
          ],
        ),
        child:
            currentHeight == collapsedHeight ? _miniPlayer(c) : _fullPlayer(c),
      ),
    );
  }

  // -------------------------
  // MINI PLAYER
  // -------------------------
  Widget _miniPlayer(AudioPlayerController c) {
    return Row(
      children: [
        const SizedBox(width: 8),

        // Small album art
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: QueryArtworkWidget(
            id: c.currentSong!.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade300,
              child: const Icon(Icons.music_note),
            ),
            artworkWidth: 50,
            artworkHeight: 50,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            c.currentSong!.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        IconButton(
          icon: Icon(c.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: c.togglePlayPause,
        ),
      ],
    );
  }

  // -------------------------
  // FULL PLAYER (STATIC ARTWORK)
  // -------------------------
  Widget _fullPlayer(AudioPlayerController c) {
    return StreamBuilder<Duration?>(
      stream: c.durationStream,
      builder: (context, snapDur) {
        final duration = snapDur.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: c.positionStream,
          builder: (context, snapPos) {
            final position = snapPos.data ?? Duration.zero;

            return Column(
              children: [
                const SizedBox(height: 10),
                const Icon(Icons.drag_handle),

                const SizedBox(height: 20),

                // STATIC CIRCULAR ALBUM ART — NO ROTATION
                ClipOval(
                  child: QueryArtworkWidget(
                    id: c.currentSong!.id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: 180,
                    artworkWidth: 180,
                    nullArtworkWidget: Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                      ),
                      child: const Icon(Icons.music_note, size: 80),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  c.currentSong!.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                Text(
                  c.currentSong!.artist ?? "Unknown Artist",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // Seekbar
                SeekBar(
                  position: position,
                  duration: duration,
                  onChangeEnd: c.seek,
                ),

                const SizedBox(height: 20),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: c.previous,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 60,
                      icon: Icon(
                        c.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                      ),
                      onPressed: c.togglePlayPause,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_next),
                      onPressed: c.next,
                    ),
                  ],
                ),

                const Spacer(),
              ],
            );
          },
        );
      },
    );
  }
}
