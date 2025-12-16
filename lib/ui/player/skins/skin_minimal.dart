// lib/ui/player/skins/skin_minimal.dart
import 'package:flutter/material.dart';
import 'package:vinu/ui/player/skins/player_skin_base.dart';
import '../../../player/audio_player_controller.dart';
import '../widgets/seekbar.dart';
import '../widgets/mini_artwork.dart';
import '../player_controls.dart';
import '../player_actions_bar.dart';

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

    return SafeArea(
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: scheme.onSurface),
                  onPressed: onClose,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.queue_music_rounded, color: scheme.onSurfaceVariant),
                  onPressed: openQueue,
                ),
              ],
            ),
          ),

          // Artwork + meta
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: MiniArtwork(songId: song.id),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  song.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  song.artist ?? 'Unknown',
                  style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
                ),

                const SizedBox(height: 18),

                // Seekbar (listens only to position)
                StreamBuilder<PositionData>(
                  stream: controller.smoothPositionStream,
                  builder: (_, snap) {
                    final pos = snap.data?.position ?? Duration.zero;
                    final dur = snap.data?.duration ?? Duration.zero;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: SeekBar(position: pos, duration: dur, onChangeEnd: controller.seek),
                    );
                  },
                ),

                const SizedBox(height: 8),
                PlayerControls(controller: controller, openQueue: openQueue),
                const SizedBox(height: 10),
                PlayerActionsBar(songId: song.id),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
