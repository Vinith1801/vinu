import 'package:flutter/material.dart';
import 'package:vinu/ui/player/player_actions_bar.dart';

import '../../../player/audio_player_controller.dart';
import '../../widgets/seekbar.dart';
import '../player_controls.dart';
import '../vinyl_artwork.dart';
import 'player_skin_base.dart';

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

    return Column(
      children: [
        // Close Button
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
              VinylArtwork(songId: song.id),

              const SizedBox(height: 20),

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

              PlayerControls(
                controller: controller,
                openQueue: openQueue,
              ),
              PlayerActionsBar(songId: song.id),
            ],
          ),
        ),
      ],
    );
  }
}
