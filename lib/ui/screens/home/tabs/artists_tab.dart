// lib/ui/screens/home/tabs/artists_tab.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../artist_songs_screen.dart';

class ArtistsTab extends StatelessWidget {
  final List<ArtistModel> artists;
  const ArtistsTab({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    if (artists.isEmpty) {
      return Center(child: Text("No artists", style: TextStyle(color: muted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: CircleAvatar(backgroundColor: scheme.surfaceContainerHighest, child: Icon(Icons.person, color: muted)),
          title: Text(a.artist, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          subtitle: Text("${a.numberOfTracks} Tracks", style: TextStyle(color: muted)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistSongsScreen(artist: a),
              ),
            );
          },
        );
      },
    );
  }
}
