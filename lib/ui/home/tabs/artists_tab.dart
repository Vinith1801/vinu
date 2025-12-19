import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../library/artist_songs_screen.dart';
import 'package:vinu/ui/shared/artwork_loader.dart';

class ArtistsTab extends StatelessWidget {
  final List<ArtistModel> artists;
  const ArtistsTab({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withAlpha((0.5 * 255).toInt());

    if (artists.isEmpty) {
      return Center(child: Text("No artists", style: TextStyle(color: muted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];

        return ListTile(
          key: ValueKey(a.id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: ArtworkLoader(
              id: a.id,
              type: ArtworkType.ARTIST,
              size: 56,
              borderRadius: BorderRadius.circular(28),
              placeholder: Container(
                color: scheme.surfaceContainerHighest,
                child: Icon(Icons.person, color: muted),
              ),
            ),
          ),
          title: Text(a.artist, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          subtitle: Text("${a.numberOfTracks} tracks", style: TextStyle(color: muted)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ArtistSongsScreen(artist: a)),
            );
          },
        );
      },
    );
  }
}
