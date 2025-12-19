import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vinu/state/player/audio_player_controller.dart';

class PlayerControls extends StatelessWidget {
  final AudioPlayerController controller;
  final VoidCallback openQueue;

  const PlayerControls({
    super.key,
    required this.controller,
    required this.openQueue,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ------------------------------------------
        // SHUFFLE & REPEAT (COMBINED LOGIC RESTORED)
        // ------------------------------------------
        Selector<AudioPlayerController, Map<String, dynamic>>(
          selector: (_, p) => {
            "shuffle": p.playback.isShuffling,
            "repeat": p.playback.loopMode,
          },
          builder: (_, data, __) {
            final shuffle = data["shuffle"] as bool;
            final repeat = data["repeat"] as LoopMode;

            IconData icon;
            Color color = scheme.onSurfaceVariant;

            if (shuffle) {
              icon = Icons.shuffle_rounded;
              color = scheme.primary;
            } else if (repeat == LoopMode.all) {
              icon = Icons.repeat_rounded;
              color = scheme.primary;
            } else if (repeat == LoopMode.one) {
              icon = Icons.repeat_one_rounded;
              color = scheme.primary;
            } else {
              icon = Icons.shuffle_rounded;
            }

            return GestureDetector(
              onTap: () {
                // EXACT SAME STATE MACHINE YOU USED
                if (!shuffle && repeat == LoopMode.off) {
                  controller.playback.toggleShuffle();
                } else if (shuffle) {
                  controller.playback.toggleShuffle();
                  if (controller.playback.loopMode != LoopMode.all) controller.playback.toggleRepeat();
                } else if (repeat == LoopMode.all) {
                  controller.playback.toggleRepeat();
                } else if (repeat == LoopMode.one) {
                  controller.playback.toggleRepeat();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 26, color: color),
              ),
            );
          },
        ),

        const SizedBox(width: 16),

        // PREVIOUS
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_previous_rounded, color: scheme.onSurface),
          onPressed: controller.playback.previous,
        ),

        // PLAY / PAUSE
        Selector<AudioPlayerController, bool>(
          selector: (_, c) => c.playback.isPlaying,
          builder: (_, isPlaying, __) {
            return IconButton(
              iconSize: 80,
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: scheme.primary,
              ),
              onPressed: controller.playback.togglePlayPause,
            );
          },
        ),

        // NEXT
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_next_rounded, color: scheme.onSurface),
          onPressed: controller.playback.next,
        ),

        const SizedBox(width: 16),

        // QUEUE BUTTON (RESTORED)
        IconButton(
          iconSize: 30,
          icon: Icon(Icons.queue_music_rounded,
              color: scheme.onSurfaceVariant),
          onPressed: openQueue,
        ),
      ],
    );
  }
}
