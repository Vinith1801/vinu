// lib/ui/player/mini_player.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/audio_player_controller.dart';
import 'widgets/mini_artwork.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioPlayerController>();
    final song = controller.currentSong;
    if (song == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    // Lift animation when playing: subtle visual cue
    final isPlaying = controller.isPlaying;
    final topPadding = isPlaying ? 6.0 : 12.0;
    final boxShadowOpacity = isPlaying ? 0.08 : 0.04;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(top: topPadding),
      child: Container(
        // Slightly taller than before so progress bar fits comfortably
        height: 92,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues( alpha:boxShadowOpacity),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),

        // Entire tile is still tappable from PlayerContainer (outer GestureDetector).
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // Keep inner taps (e.g. on artwork) interactive if needed
            onTap: null, // PlayerContainer handles full-open tap
            child: Column(
              children: [
                // MAIN ROW
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        // Artwork (larger)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: RepaintBoundary(
                              child: MiniArtwork(
                                songId: song.id,
                                placeholder: Container(
                                  height: 64,
                                  width: 64,
                                  color: scheme.surfaceContainerHighest,
                                  child: Icon(Icons.music_note, color: scheme.onSurfaceVariant),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Title + Artist
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Play / Pause Button
                        IconButton(
                          iconSize: 34,
                          icon: Icon(
                            controller.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                            color: scheme.primary,
                          ),
                          onPressed: controller.togglePlayPause,
                        ),
                      ],
                    ),
                  ),
                ),

                // PROGRESS BAR (compact, live)
                StreamBuilder<PositionData>(
                  stream: controller.smoothPositionStream,
                  builder: (_, snap) {
                    final pos = snap.data?.position ?? Duration.zero;
                    final dur = snap.data?.duration ?? Duration.zero;

                    // Avoid division by zero
                    final double value;
                    if (dur.inMilliseconds <= 0) {
                      value = 0.0;
                    } else {
                      value = (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
                    }

                    return Column(
                      children: [
                        // Thin tappable progress indicator — tapping jumps to a relative position
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragUpdate: (details) {
                            // Optional: real-time drag seek (coarse)
                            // We map the drag position to relative percent using RenderBox hit test.
                          },
                          onTapDown: (tap) {
                            // Jump to tapped position inside the progress bar
                            final box = context.findRenderObject() as RenderBox?;
                            if (box == null) return;
                            final local = box.globalToLocal(tap.globalPosition);
                            final width = box.size.width;
                            if (width <= 0 || dur.inMilliseconds <= 0) return;
                            final relative = (local.dx / width).clamp(0.0, 1.0);
                            final seekTo = Duration(milliseconds: (dur.inMilliseconds * relative).toInt());
                            controller.seek(seekTo);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                minHeight: 4,
                                value: value,
                                backgroundColor: scheme.onSurfaceVariant.withValues( alpha:0.12),
                                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                              ),
                            ),
                          ),
                        ),

                        
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}