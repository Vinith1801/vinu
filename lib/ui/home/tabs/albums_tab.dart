import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../library/album_songs_screen.dart';
import 'package:vinu/ui/shared/artwork_loader.dart';

class AlbumsTab extends StatelessWidget {
  final List<AlbumModel> albums;
  const AlbumsTab({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withAlpha((0.5 * 255).toInt());

    if (albums.isEmpty) {
      return Center(child: Text("No albums", style: TextStyle(color: muted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final a = albums[i];

        return ListTile(
          key: ValueKey(a.id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ArtworkLoader(
              id: a.id,
              type: ArtworkType.ALBUM,
              size: 56,
              borderRadius: BorderRadius.circular(8),
              placeholder: Container(
                color: scheme.surfaceContainerHighest,
                child: Icon(Icons.album_rounded, color: muted),
              ),
            ),
          ),
          title: Text(a.album, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          subtitle: Text("${a.numOfSongs} songs", style: TextStyle(color: muted)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AlbumSongsScreen(album: a)),
            );
          },
        );
      },
    );
  }
}
