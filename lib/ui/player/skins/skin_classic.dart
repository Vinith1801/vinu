import 'package:flutter/material.dart';
import 'package:vinu/ui/player/player_actions_bar.dart';

import '../../../player/audio_player_controller.dart';
import '../widgets/seekbar.dart';
import '../player_controls.dart';
import '../widgets/vinyl_artwork.dart';
import 'player_skin_base.dart';
import '../widgets/volume_slider.dart';

class SkinClassic extends PlayerSkin {
  const SkinClassic({
    super.key,
    required super.controller,
    required super.onClose,
    required super.openQueue,
  });

  @override
  Widget build(BuildContext context) {
    final song = controller.currentSong!;
    final scheme = Theme.of(context).colorScheme;

    // Track whether artwork or volume is shown
    final ValueNotifier<bool> showVolume = ValueNotifier(false);

    return ValueListenableBuilder<bool>(
      valueListenable: showVolume,
      builder: (_, volumeVisible, __) {
        return Column(
          children: [
            // CLOSE BUTTON
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 32, color: scheme.onSurface),
                  onPressed: onClose,
                ),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // =======================================================
                  // ARTWORK ↔ VOLUME SWITCHER
                  // =======================================================
                  SizedBox(
                    height: 360,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: child.key == const ValueKey("VOLUME")
                                ? const Offset(0, 0.2)
                                : const Offset(0, -0.2),
                            end: Offset.zero,
                          ).animate(anim),
                          child: FadeTransition(opacity: anim, child: child),
                        );
                      },
                      child: volumeVisible
                          ? _buildVolumePanel(showVolume)
                          : _buildArtwork(showVolume, song.id),
                    ),
                  ),
                  // =======================================================

                  const SizedBox(height: 20),

                  // TITLE
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    song.artist ?? "Unknown",
                    style: TextStyle(
                      fontSize: 15,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SEEK BAR
                  StreamBuilder<PositionData>(
                    stream: controller.smoothPositionStream,
                    builder: (_, snap) {
                      final pos = snap.data?.position ?? Duration.zero;
                      final dur = snap.data?.duration ?? Duration.zero;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SeekBar(
                          position: pos,
                          duration: dur,
                          onChangeEnd: controller.seek,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  PlayerControls(controller: controller, openQueue: openQueue),
                  PlayerActionsBar(songId: song.id),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ARTWORK VIEW
  // ============================================================
  Widget _buildArtwork(ValueNotifier<bool> showVolume, int songId) {
    return GestureDetector(
      key: const ValueKey("ARTWORK"),
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -10) {
          showVolume.value = true; // swipe up → show volume
        }
      },
      child: VinylArtwork(songId: songId),
    );
  }

  // ============================================================
  // VOLUME PANEL VIEW
  // ============================================================
  Widget _buildVolumePanel(ValueNotifier<bool> showVolume) {
    return GestureDetector(
      key: const ValueKey("VOLUME"),
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 10) {
          showVolume.value = false; // swipe down → back to artwork
        }
      },
      child: const Center(
        child: VolumeSlider(),
      ),
    );
  }
}
