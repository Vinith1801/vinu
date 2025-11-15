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
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: QueryArtworkWidget(
          id: songId,
          type: ArtworkType.AUDIO,
          nullArtworkWidget: Container(
            width: 50,
            height: 50,
            color: Colors.grey.shade300,
            child: const Icon(Icons.music_note, size: 28),
          ),
          artworkHeight: 50,
          artworkWidth: 50,
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
