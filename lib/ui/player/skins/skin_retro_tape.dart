// lib/ui/player/skins/skin_retro_tape.dart
import 'package:flutter/material.dart';
import 'package:vinu/ui/player/skins/player_skin_base.dart';
import '../../../player/audio_player_controller.dart';
import '../../widgets/seekbar.dart';
import '../mini_artwork.dart';
import '../player_controls.dart';
import '../player_actions_bar.dart';

class SkinRetroTape extends PlayerSkin {
  const SkinRetroTape({
    super.key,
    required super.controller,
    required super.onClose,
    required super.openQueue,
  });

  @override
  Widget build(BuildContext context) {
    final song = controller.currentSong!;
    final scheme = Theme.of(context).colorScheme;

    // warm surface color derived from primary, with subdued tone
    final warm = Color.lerp(scheme.primary, scheme.onSurface, 0.8) ?? scheme.primary;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.keyboard_arrow_down_rounded, color: scheme.onSurface), onPressed: onClose),
                const Spacer(),
                IconButton(icon: Icon(Icons.more_horiz, color: scheme.onSurfaceVariant), onPressed: openQueue),
              ],
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // warm card with artwork window
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: warm.withValues( alpha:0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outline.withValues( alpha:0.06)),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 240, height: 160, child: MiniArtwork(songId: song.id))),
                      const SizedBox(height: 12),
                      Text(song.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      const SizedBox(height: 6),
                      Text(song.artist ?? 'Unknown', style: TextStyle(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      StreamBuilder<PositionData>(
                        stream: controller.smoothPositionStream,
                        builder: (_, snap) {
                          final pos = snap.data?.position ?? Duration.zero;
                          final dur = snap.data?.duration ?? Duration.zero;
                          return SeekBar(position: pos, duration: dur, onChangeEnd: controller.seek);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                PlayerControls(controller: controller, openQueue: openQueue),
                const SizedBox(height: 8),
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
