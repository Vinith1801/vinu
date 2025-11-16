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
  double collapsedHeight = 78;
  double expandedHeight = 0;
  double currentHeight = 78;

  late AnimationController rotateCtrl;

  @override
  void initState() {
    super.initState();
    rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    expandedHeight = MediaQuery.of(context).size.height * 0.80;
  }

  @override
  void dispose() {
    rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Provider.of<AudioPlayerController>(context);

    if (c.currentSong == null) return const SizedBox.shrink();

    // Pause rotation if music is paused
    c.isPlaying ? rotateCtrl.repeat() : rotateCtrl.stop();

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
        duration: const Duration(milliseconds: 180),
        height: currentHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(currentHeight == collapsedHeight ? 1 : 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: currentHeight == collapsedHeight
            ? _mini(c)
            : _full(c),
      ),
    );
  }

  // ----------------------------------------------------------
  // MINI PLAYER — PREMIUM GLASS CARD
  // ----------------------------------------------------------
  Widget _mini(AudioPlayerController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // ARTWORK
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: QueryArtworkWidget(
              id: c.currentSong!.id,
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

          // TITLE
          Expanded(
            child: Text(
              c.currentSong!.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // PLAY/PAUSE
          IconButton(
            iconSize: 32,
            icon: Icon(
              c.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            onPressed: c.togglePlayPause,
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // FULL PLAYER — BLUR BACKGROUND + ROTATION ART
  // ----------------------------------------------------------
  Widget _full(AudioPlayerController c) {
    return StreamBuilder<Duration?>(
      stream: c.durationStream,
      builder: (context, snapDur) {
        final duration = snapDur.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: c.positionStream,
          builder: (context, snapPos) {
            final position = snapPos.data ?? Duration.zero;

            return Stack(
              children: [
                // BACKGROUND BLUR ARTWORK
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.20,
                    child: QueryArtworkWidget(
                      id: c.currentSong!.id,
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

                // CONTENT
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

                    // ROTATING ALBUM ART
                    RotationTransition(
                      turns: rotateCtrl,
                      child: ClipOval(
                        child: QueryArtworkWidget(
                          id: c.currentSong!.id,
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

                    // TITLE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        c.currentSong!.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ARTIST
                    Text(
                      c.currentSong!.artist ?? "Unknown Artist",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // SEEK BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SeekBar(
                        position: position,
                        duration: duration,
                        onChangeEnd: c.seek,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CONTROLS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 38,
                          icon: const Icon(Icons.skip_previous_rounded),
                          onPressed: c.previous,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 70,
                          icon: Icon(
                            c.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                          ),
                          onPressed: c.togglePlayPause,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 38,
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: c.next,
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
      },
    );
  }
}
