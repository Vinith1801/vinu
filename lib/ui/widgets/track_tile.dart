import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class TrackTile extends StatelessWidget {
  final String title;
  final String artist;
  final int songId;
  final VoidCallback onTap;

  const TrackTile({
    super.key,
    required this.title,
    required this.artist,
    required this.songId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
    leading: QueryArtworkWidget(
      id: songId,
      type: ArtworkType.AUDIO,
      artworkHeight: 50,
      artworkWidth: 50,
      artworkFit: BoxFit.cover,
      artworkBorder: BorderRadius.circular(8), // <-- soft square corners
      nullArtworkWidget: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8), // match the radius
        ),
        child: const Icon(Icons.music_note, size: 28),
      ),
    ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
