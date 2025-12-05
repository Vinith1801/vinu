import 'package:flutter/material.dart';
import 'package:vinu/player/audio_player_controller.dart';
import 'package:vinu/ui/player/mini_artwork.dart';
import 'package:vinu/ui/player/player_actions_bar.dart';
import '../player_controls.dart';
import '../../widgets/seekbar.dart';
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

    return Column(
      children: [
        // Close Button
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(Icons.close, color: scheme.onSurface),
            onPressed: onClose,
          ),
        ),

        const SizedBox(height: 40),

        // Big Artwork (flat)
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 260,
            height: 260,
            child: MiniArtwork(songId: song.id),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          song.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),

        Text(
          song.artist ?? "Unknown",
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),

        const SizedBox(height: 16),

        StreamBuilder<PositionData>(
          stream: controller.smoothPositionStream,
          builder: (_, snap) {
            final pos = snap.data?.position ?? Duration.zero;
            final dur = snap.data?.duration ?? Duration.zero;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SeekBar(
                position: pos,
                duration: dur,
                onChangeEnd: controller.seek,
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        PlayerControls(controller: controller, openQueue: openQueue),
        PlayerActionsBar(songId: song.id),
      ],
    );
  }
}
