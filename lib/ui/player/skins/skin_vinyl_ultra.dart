// lib/ui/player/skins/skin_vinyl_ultra.dart
import 'package:flutter/material.dart';
import 'package:vinu/ui/player/skins/player_skin_base.dart';
import '../../../player/audio_player_controller.dart';
import '../widgets/vinyl_artwork.dart';
import '../widgets/seekbar.dart';
import '../player_controls.dart';
import '../player_actions_bar.dart';

class SkinVinylUltra extends PlayerSkin {
  const SkinVinylUltra({
    super.key,
    required super.controller,
    required super.onClose,
    required super.openQueue,
  });

  @override
  Widget build(BuildContext context) {
    final song = controller.currentSong!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(icon: Icon(Icons.close, color: scheme.onSurface), onPressed: onClose),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Vinyl with subtle ring
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [scheme.primary.withValues( alpha:0.06), Colors.transparent]),
                    ),
                    child: VinylArtwork(songId: song.id, size: 300),
                  ),

                  const SizedBox(height: 18),
                  Text(song.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: scheme.onSurface)),
                  const SizedBox(height: 6),
                  Text(song.artist ?? 'Unknown', style: TextStyle(color: scheme.onSurfaceVariant)),

                  const SizedBox(height: 18),

                  StreamBuilder<PositionData>(
                    stream: controller.smoothPositionStream,
                    builder: (_, snap) {
                      final pos = snap.data?.position ?? Duration.zero;
                      final dur = snap.data?.duration ?? Duration.zero;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: SeekBar(position: pos, duration: dur, onChangeEnd: controller.seek),
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  PlayerControls(controller: controller, openQueue: openQueue),
                  const SizedBox(height: 8),
                  PlayerActionsBar(songId: song.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
