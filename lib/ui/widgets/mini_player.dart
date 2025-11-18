import 'dart:async';
// import 'dart:math' as math;
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

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  static const double collapsedHeight = 78;
  double expandedHeight = 0;
  double currentHeight = collapsedHeight;

  late final AnimationController rotateCtrl;
  StreamSubscription<bool>? _playingSub;

  @override
  void initState() {
    super.initState();
    rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Listen to playing stream to control rotation WITHOUT rebuilding UI
    // Use a post-frame read of controller to avoid context issues in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<AudioPlayerController>();
      _playingSub = c.playingStream.listen((playing) {
        if (playing) {
          if (!rotateCtrl.isAnimating) rotateCtrl.repeat();
        } else {
          rotateCtrl.stop();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    expandedHeight = MediaQuery.of(context).size.height * 0.80;
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only watch the currentSongId to know if we should show the mini player
    final currentSongId = context.select<AudioPlayerController, int?>(
      (c) => c.currentSongId,
    );

    // If no song is loaded, hide the mini player
    if (currentSongId == null) return const SizedBox.shrink();

    // Use read for controller actions so this build doesn't tie to controller ticks
    final controller = context.read<AudioPlayerController>();

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          currentHeight -= details.delta.dy;
          currentHeight = currentHeight.clamp(collapsedHeight, expandedHeight);
        });
      },
      onVerticalDragEnd: (_) {
        setState(() {
          currentHeight =
              currentHeight > expandedHeight / 2 ? expandedHeight : collapsedHeight;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: currentHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(currentHeight == collapsedHeight ? 1 : 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: currentHeight == collapsedHeight ? _mini(controller) : _full(controller),
      ),
    );
  }

  Widget _mini(AudioPlayerController controller) {
    // Use selectors to only rebuild widgets that actually change
    final songId = controller.currentSong?.id;
    final songTitle = controller.currentSong?.title ?? '';
    final artworkId = controller.currentSong?.id ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: QueryArtworkWidget(
              id: artworkId,
              type: ArtworkType.AUDIO,
              artworkHeight: 58,
              artworkWidth: 58,
              nullArtworkWidget: Container(
                width: 58,
                height: 58,
                color: Colors.grey.shade300,
                child: const Icon(Icons.music_note, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              songTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),

          // Play/pause: only rebuild this button when playing state changes
          Selector<AudioPlayerController, bool>(
            selector: (_, c) => c.isPlaying,
            builder: (_, isPlaying, __) {
              return IconButton(
                iconSize: 32,
                icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: () => context.read<AudioPlayerController>().togglePlayPause(),
              );
            },
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _full(AudioPlayerController controller) {
    // Combined PositionData stream updates at human-readable frequency
    return StreamBuilder<PositionData>(
      stream: controller.positionDataStream,
      builder: (context, snap) {
        final position = snap.data?.position ?? Duration.zero;
        final duration = snap.data?.duration ?? Duration.zero;

        final title = controller.currentSong?.title ?? '';
        final artist = controller.currentSong?.artist ?? 'Unknown Artist';
        final artworkId = controller.currentSong?.id ?? 0;

        return Stack(
          children: [
            // Blurred faded artwork background
            Positioned.fill(
              child: Opacity(
                opacity: 0.20,
                child: QueryArtworkWidget(
                  id: artworkId,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Container(color: Colors.black12),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white,
                      Colors.white60,
                      Colors.white24,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),

                // Rotating album art (rotation controlled by playingStream; no rebuild required)
                RotationTransition(
                  turns: rotateCtrl,
                  child: ClipOval(
                    child: QueryArtworkWidget(
                      id: artworkId,
                      type: ArtworkType.AUDIO,
                      artworkHeight: 220,
                      artworkWidth: 220,
                      nullArtworkWidget: Container(
                        height: 220,
                        width: 220,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black12,
                        ),
                        child: const Icon(Icons.music_note, size: 90),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 6),
                Text(artist, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
                const SizedBox(height: 26),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SeekBar(
                    position: position,
                    duration: duration,
                    onChangeEnd: (pos) => controller.seek(pos),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 38,
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: () => controller.previous(),
                    ),
                    const SizedBox(width: 20),
                    Selector<AudioPlayerController, bool>(
                      selector: (_, c) => c.isPlaying,
                      builder: (_, isPlaying, __) {
                        return IconButton(
                          iconSize: 70,
                          icon: Icon(isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded),
                          onPressed: () => context.read<AudioPlayerController>().togglePlayPause(),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 38,
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: () => controller.next(),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ],
        );
      },
    );
  }
}
