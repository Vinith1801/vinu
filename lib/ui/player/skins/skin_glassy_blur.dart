// lib/ui/player/skins/skin_glassy_blur.dart
import 'package:flutter/material.dart';
import 'package:vinu/ui/player/skins/player_skin_base.dart';
import 'dart:ui';
import '../../../player/audio_player_controller.dart';
import '../widgets/seekbar.dart';
import '../widgets/mini_artwork.dart';
import '../player_controls.dart';
import '../player_actions_bar.dart';

class SkinGlassyBlur extends PlayerSkin {
  const SkinGlassyBlur({
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
        child: Stack(
          children: [
            // Soft gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.surface.withValues( alpha:0.98), scheme.primary.withValues( alpha:0.02)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: Row(
                    children: [
                      IconButton(icon: Icon(Icons.close, color: scheme.onSurface), onPressed: onClose),
                      const Spacer(),
                      IconButton(icon: Icon(Icons.queue_music_rounded, color: scheme.onSurfaceVariant), onPressed: openQueue),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues( alpha:0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: scheme.outline.withValues( alpha:0.06)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 240, height: 240, child: MiniArtwork(songId: song.id))),
                              const SizedBox(height: 12),
                              Text(song.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface)),
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
                              const SizedBox(height: 10),
                              PlayerControls(controller: controller, openQueue: openQueue),
                              const SizedBox(height: 8),
                              PlayerActionsBar(songId: song.id),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
