// lib/ui/player/full_player.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/player/player_skin_controller.dart';
import 'package:vinu/ui/player/skins/skin_classic.dart';
import 'package:vinu/ui/player/skins/skin_minimal.dart';

import '../../player/audio_player_controller.dart';
import 'mini_artwork.dart';

class FullPlayer extends StatefulWidget {
  final VoidCallback onClose;

  const FullPlayer({super.key, required this.onClose});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {

  // -----------------------------
  // QUEUE BOTTOM SHEET
  // -----------------------------
  void _openQueue() {
    final controller = context.read<AudioPlayerController>();
    final queue = controller.playlist;
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: scheme.outline.withValues( alpha:0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Up Next",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: queue.length,
                  itemBuilder: (_, i) {
                    final song = queue[i];
                    final isCurrent =
                        controller.currentIndex == i;

                    return ListTile(
                      tileColor: isCurrent
                          ? scheme.primary.withValues( alpha:0.5)
                          : null,
                      leading: SizedBox(
                        width: 48,
                        height: 48,
                        child: MiniArtwork(songId: song.id),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        song.artist ?? "Unknown Artist",
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      trailing: isCurrent
                          ? Icon(Icons.play_arrow,
                              color: scheme.primary)
                          : null,
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.playIndex(i);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  final controller = context.watch<AudioPlayerController>();
  final skinIndex = context.watch<PlayerSkinController>().selectedSkin;

  final skins = [
  SkinClassic(controller: controller, onClose: widget.onClose, openQueue: _openQueue),
  SkinMinimal(controller: controller, onClose: widget.onClose, openQueue: _openQueue),];

  return Scaffold(
    body: SafeArea(child: skins[skinIndex]),
  );
}

}
