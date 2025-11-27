// lib/ui/screens/home/tabs/playlists_tab.dart
import 'package:flutter/material.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue_music_rounded, size: 72, color: muted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text("No playlists yet", style: TextStyle(color: muted)),
        ],
      ),
    );
  }
}
