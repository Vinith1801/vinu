// lib/ui/player/skins/skin_minimal_pro.dart
import 'package:flutter/material.dart';
import 'package:vinu/ui/player/skins/player_skin_base.dart';
import '../../../player/audio_player_controller.dart';
import '../widgets/seekbar.dart';
import '../widgets/mini_artwork.dart';
import '../player_controls.dart';
import '../player_actions_bar.dart';

class SkinMinimalPro extends PlayerSkin {
  const SkinMinimalPro({
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
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close_rounded, color: scheme.onSurface),
                  onPressed: onClose,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
                  onPressed: openQueue,
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Slight elevated card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues( alpha:0.04), blurRadius: 12, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(width: 120, height: 120, child: MiniArtwork(songId: song.id)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(song.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text(song.artist ?? 'Unknown', style: TextStyle(color: scheme.onSurfaceVariant)),
                            const SizedBox(height: 8),
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
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                PlayerControls(controller: controller, openQueue: openQueue),
                const SizedBox(height: 8),
                PlayerActionsBar(songId: song.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
