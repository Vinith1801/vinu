import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/state/player/audio_player_controller.dart';
import 'mini_artwork.dart';

class QueueBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Consumer<AudioPlayerController>(
          builder: (context, controller, __) {
            final queue = controller.queue.playlist;
            final scheme = Theme.of(context).colorScheme;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: scheme.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Up Next",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: queue.length,
                      itemBuilder: (_, i) {
                        final song = queue[i];
                        final isCurrent =
                            controller.queue.currentIndex == i;

                        return ListTile(
                          tileColor: isCurrent
                              ? scheme.primary.withValues(alpha: 0.1)
                              : null,
                          leading: MiniArtwork(songId: song.id),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle:
                              Text(song.artist ?? "Unknown Artist"),
                          trailing: isCurrent
                              ? Icon(Icons.play_arrow,
                                  color: scheme.primary)
                              : null,
                          onTap: () {
                            Navigator.of(context).pop();
                            controller.queue.playSong(song);
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
      },
    );
  }
}
