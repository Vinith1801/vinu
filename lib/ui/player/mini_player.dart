import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/state/player/audio_player_controller.dart';
import 'package:vinu/state/player/position_controller.dart';
import 'widgets/mini_artwork.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioPlayerController>();
    final song = controller.queue.currentSong;
    if (song == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final isPlaying = controller.playback.isPlaying;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 280),
      padding: EdgeInsets.only(top: isPlaying ? 6 : 12),
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isPlaying ? 0.08 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          children: [
            // MAIN ROW
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: MiniArtwork(
                          songId: song.id,
                          placeholder: Container(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(Icons.music_note,
                                color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              color: scheme.onSurface,
                            ),
                          ),
                          Text(
                            song.artist ?? 'Unknown Artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      iconSize: 34,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: scheme.primary,
                      ),
                      onPressed: controller.playback.togglePlayPause,
                    ),
                  ],
                ),
              ),
            ),

            // PROGRESS BAR
            StreamBuilder<PositionData>(
              stream: controller.position.smooth,
              builder: (_, snap) {
                final pos = snap.data?.position ?? Duration.zero;
                final dur = snap.data?.duration ?? Duration.zero;

                final value = dur.inMilliseconds == 0
                    ? 0.0
                    : (pos.inMilliseconds / dur.inMilliseconds)
                        .clamp(0.0, 1.0);

                return LayoutBuilder(
                  builder: (_, c) {
                    return GestureDetector(
                      onTapDown: (tap) {
                        if (dur.inMilliseconds == 0) return;
                        final relative =
                            (tap.localPosition.dx / c.maxWidth)
                                .clamp(0.0, 1.0);
                        controller.playback.seek(
                          Duration(
                            milliseconds:
                                (dur.inMilliseconds * relative).toInt(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            value: value,
                            backgroundColor:
                                scheme.onSurfaceVariant.withValues(alpha: 0.12),
                            valueColor:
                                AlwaysStoppedAnimation(scheme.primary),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
