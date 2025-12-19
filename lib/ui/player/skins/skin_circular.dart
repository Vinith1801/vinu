import 'package:flutter/material.dart';
import 'package:vinu/state/player/position_controller.dart';
import 'package:vinu/ui/player/player_actions_bar.dart';
import 'package:vinu/ui/player/player_controls.dart';
import 'package:vinu/ui/player/skins/player_skin_base.dart';
import 'package:vinu/ui/player/widgets/circular_seekbar.dart';
import 'package:vinu/ui/player/widgets/mini_artwork.dart';
import 'package:vinu/ui/player/widgets/player_volume_overlay.dart';
import 'package:vinu/ui/player/widgets/player_artwork_surface.dart';

class SkinCircular extends PlayerSkin {
  const SkinCircular({
    super.key,
    required super.controller,
    required super.onClose,
    required super.openQueue,
  });

  @override
  Widget build(BuildContext context) {
    final song = controller.queue.currentSong!;
    final scheme = Theme.of(context).colorScheme;
    final showVolume = ValueNotifier(false);

    return ValueListenableBuilder<bool>(
      valueListenable: showVolume,
      builder: (_, volumeVisible, __) {
        return Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          onPressed: onClose,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.queue_music_rounded),
                          onPressed: openQueue,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreamBuilder<PositionData>(
                          stream: controller.position.smooth,
                          builder: (_, snap) {
                            final pos =
                                snap.data?.position ?? Duration.zero;
                            final dur =
                                snap.data?.duration ?? Duration.zero;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularSeekBar(
                                  size: 300,
                                  position: pos,
                                  duration: dur,
                                  onSeek: controller.playback.seek,
                                ),

                                PlayerArtworkSurface(
                                  borderRadius: BorderRadius.circular(999),
                                  artwork: GestureDetector(
                                    onVerticalDragEnd: (d) {
                                      if ((d.primaryVelocity ?? 0) < -200) {
                                        showVolume.value = true;
                                      }
                                    },
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 220,
                                        height: 220,
                                        child: MiniArtwork(songId: song.id),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          song.artist ?? 'Unknown',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 20),

                        PlayerControls(
                          controller: controller,
                          openQueue: openQueue,
                        ),

                        const SizedBox(height: 12),

                        PlayerActionsBar(songId: song.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            PlayerVolumeOverlay(
              visible: volumeVisible,
              onDismiss: () => showVolume.value = false,
            ),
          ],
        );
      },
    );
  }
}
