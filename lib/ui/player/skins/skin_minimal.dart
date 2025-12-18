import 'package:flutter/material.dart';
import '../../../player/audio_player_controller.dart';
import '../widgets/seekbar.dart';
import '../widgets/mini_artwork.dart';
import '../player_controls.dart';
import '../player_actions_bar.dart';
import '../widgets/player_artwork_surface.dart';
import '../widgets/player_volume_overlay.dart';
import 'player_skin_base.dart';

class SkinMinimal extends PlayerSkin {
  const SkinMinimal({
    super.key,
    required super.controller,
    required super.onClose,
    required super.openQueue,
  });

  @override
  Widget build(BuildContext context) {
    final song = controller.currentSong!;
    final scheme = Theme.of(context).colorScheme;

    final ValueNotifier<bool> showVolume = ValueNotifier(false);

    return ValueListenableBuilder<bool>(
      valueListenable: showVolume,
      builder: (_, volumeVisible, __) {
        return Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: scheme.onSurface,
                          ),
                          onPressed: onClose,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.queue_music_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                          onPressed: openQueue,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PlayerArtworkSurface(
                          borderRadius: BorderRadius.circular(16),
                          artwork: GestureDetector(
                            onVerticalDragEnd: (d) {
                              if ((d.primaryVelocity ?? 0) < -200) {
                                showVolume.value = true;
                              }
                            },
                            child: SizedBox(
                              width: 280,
                              height: 280,
                              child: MiniArtwork(songId: song.id),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          song.artist ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 18),

                        StreamBuilder<PositionData>(
                          stream: controller.smoothPositionStream,
                          builder: (_, snap) {
                            final pos =
                                snap.data?.position ?? Duration.zero;
                            final dur =
                                snap.data?.duration ?? Duration.zero;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: SeekBar(
                                position: pos,
                                duration: dur,
                                onChangeEnd: controller.seek,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        PlayerControls(
                          controller: controller,
                          openQueue: openQueue,
                        ),

                        const SizedBox(height: 10),

                        PlayerActionsBar(songId: song.id),

                        const SizedBox(height: 16),
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
