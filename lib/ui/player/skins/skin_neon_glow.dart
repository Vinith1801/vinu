// lib/ui/player/skins/skin_neon_glow.dart
import 'package:flutter/material.dart';
import 'package:vinu/ui/player/skins/player_skin_base.dart';
import '../../../player/audio_player_controller.dart';
import '../widgets/seekbar.dart';
import '../widgets/mini_artwork.dart';
import '../player_controls.dart';
import '../player_actions_bar.dart';

// Accent glow skin: tasteful, very subtle glow behind artwork
class SkinNeonGlow extends PlayerSkin {
  const SkinNeonGlow({
    super.key,
    required super.controller,
    required super.onClose,
    required super.openQueue,
  });

  Color _accent(ColorScheme s) {
    // choose an accent that contrasts bpased on brightness
    return s.primary;
  }

  @override
  Widget build(BuildContext context) {
    final song = controller.currentSong!;
    final scheme = Theme.of(context).colorScheme;
    final accent = _accent(scheme);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.keyboard_arrow_down_rounded, color: scheme.onSurface), onPressed: onClose),
                const Spacer(),
                IconButton(icon: Icon(Icons.queue_music_rounded, color: scheme.onSurfaceVariant), onPressed: openQueue),
              ],
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // soft glow
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: accent.withValues( alpha:0.12), blurRadius: 44, spreadRadius: 8),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(width: 260, height: 260, child: MiniArtwork(songId: song.id)),
                  ),
                ),

                const SizedBox(height: 16),
                Text(song.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                const SizedBox(height: 6),
                Text(song.artist ?? 'Unknown', style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 18),

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

                const SizedBox(height: 10),
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
