import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // <- ADD THIS
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
  static const double collapsedHeight = 80;
  double expandedHeight = 0;
  double currentHeight = collapsedHeight;

  late final AnimationController rotateCtrl;

  // ===== Artwork cache to prevent flicker =====
  SongModel? _cachedSong;
  Widget? _cachedArtwork;

  @override
  void initState() {
    super.initState();
    rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    expandedHeight = MediaQuery.of(context).size.height * 0.82;
  }

  @override
  void dispose() {
    rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSongId =
        context.select<AudioPlayerController, int?>((c) => c.currentSongId);

    if (currentSongId == null) return const SizedBox.shrink();

    final controller = context.read<AudioPlayerController>();
    final song = controller.currentSong!;

    // ===== Cache artwork to remove flicker =====
    if (_cachedSong == null || _cachedSong!.id != song.id) {
      _cachedSong = song;

      _cachedArtwork = ClipOval(
        child: QueryArtworkWidget(
          id: song.id,
          type: ArtworkType.AUDIO,
          artworkWidth: 260,
          artworkHeight: 260,
          nullArtworkWidget: Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black12,
            ),
            child: const Icon(Icons.music_note, size: 90),
          ),
        ),
      );
    }

    // ==========================================================
    // DRAGGABLE CONTAINER
    // ==========================================================
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          currentHeight -= details.delta.dy;
          currentHeight = currentHeight.clamp(collapsedHeight, expandedHeight);
        });
      },
      onVerticalDragEnd: (_) {
        setState(() {
          currentHeight = currentHeight > expandedHeight / 2
              ? expandedHeight
              : collapsedHeight;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: currentHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: currentHeight < collapsedHeight + 60
            ? _mini(controller)
            : _full(controller),
      ),
    );
  }

  // ==========================================================
  // MINI PLAYER (collapsed view)
  // ==========================================================
  Widget _mini(AudioPlayerController c) {
    final song = c.currentSong!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkHeight: 58,
              artworkWidth: 58,
              nullArtworkWidget: Container(
                width: 58,
                height: 58,
                color: Colors.grey.shade200,
                child: const Icon(Icons.music_note, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song.artist ?? "Unknown Artist",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Selector<AudioPlayerController, bool>(
            selector: (_, c) => c.isPlaying,
            builder: (_, isPlaying, __) => IconButton(
              iconSize: 30,
              icon: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black87,
              ),
              onPressed: c.togglePlayPause,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ==========================================================
  // FULL PLAYER (expanded view)
  // ==========================================================
  Widget _full(AudioPlayerController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<PositionData>(
      stream: controller.positionDataStream,
      builder: (context, snap) {
        final duration = snap.data?.duration ?? Duration.zero;
        final position = snap.data?.position ?? Duration.zero;
        final song = controller.currentSong!;

        return Stack(
          children: [
            // Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF000000),
                            Color(0xFF0A0A0A),
                            Color(0xFF111111),
                          ],
                        )
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Color(0xFFF5F5F5),
                            Color(0xFFEDEDED),
                          ],
                        ),
                ),
              ),
            ),

            if (isDark)
              Positioned(
                top: 130,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 290,
                    height: 290,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        radius: 0.8,
                      ),
                    ),
                  ),
                ),
              ),

            Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.25)
                        : Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 28),

                // Rotating ARTWORK
                Selector<AudioPlayerController, bool>(
                  selector: (_, c) => c.isPlaying,
                  builder: (_, isPlaying, __) {
                    if (isPlaying) {
                      if (!rotateCtrl.isAnimating) rotateCtrl.repeat();
                    } else {
                      rotateCtrl.stop();
                    }
                    return RotationTransition(
                      turns: rotateCtrl,
                      child: _cachedArtwork!,
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  song.artist ?? "Unknown Artist",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? Colors.white70
                        : Colors.black.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 28),

                // Seek bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SeekBar(
                    position: position,
                    duration: duration,
                    onChangeEnd: controller.seek,
                  ),
                ),

                const SizedBox(height: 30),

                // ======================================================
                // CONTROL BUTTONS (With Shuffle + Repeat)
                // ======================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // =================== SHUFFLE ===================
                    Selector<AudioPlayerController, bool>(
                      selector: (_, c) => c.isShuffling,
                      builder: (_, isOn, __) {
                        return GestureDetector(
                          onTap: controller.toggleShuffle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOn
                                  ? Colors.green.withOpacity(0.18)
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.shuffle_rounded,
                              size: 26,
                              color:
                                  isOn ? Colors.green : Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 16),

                    // PREVIOUS
                    IconButton(
                      iconSize: 38,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: controller.previous,
                    ),

                    const SizedBox(width: 12),

                    // PLAY / PAUSE
                    Selector<AudioPlayerController, bool>(
                      selector: (_, c) => c.isPlaying,
                      builder: (_, isPlaying, __) => IconButton(
                        iconSize: 80,
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: controller.togglePlayPause,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // NEXT
                    IconButton(
                      iconSize: 38,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: controller.next,
                    ),

                    const SizedBox(width: 16),

                    // =================== REPEAT ===================
                    Selector<AudioPlayerController, LoopMode>(
                      selector: (_, c) => c.loopMode,
                      builder: (_, mode, __) {
                        IconData icon;
                        Color color;

                        switch (mode) {
                          case LoopMode.one:
                            icon = Icons.repeat_one_rounded;
                            color = Colors.blue;
                            break;
                          case LoopMode.all:
                            icon = Icons.repeat_rounded;
                            color = Colors.blue;
                            break;
                          default:
                            icon = Icons.repeat_rounded;
                            color = Colors.grey.shade600;
                        }

                        return GestureDetector(
                          onTap: controller.toggleRepeat,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (mode == LoopMode.off)
                                  ? Colors.transparent
                                  : Colors.blue.withOpacity(0.18),
                            ),
                            child: Icon(
                              icon,
                              size: 26,
                              color: color,
                            ),
                          ),
                        );
                      },
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
