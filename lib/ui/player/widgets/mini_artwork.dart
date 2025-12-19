import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vinu/ui/shared/artwork_loader.dart';

class MiniArtwork extends StatelessWidget {
  final int songId;
  final Widget? placeholder;

  const MiniArtwork({super.key, required this.songId, this.placeholder});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ArtworkLoader(
      id: songId,
      type: ArtworkType.AUDIO,
      size: 58,
      borderRadius: BorderRadius.circular(8),
      placeholder: placeholder ??
          Container(
            color: scheme.surfaceContainerHighest,
            child: Icon(Icons.music_note, size: 26, color: scheme.onSurface),
          ),
    );
  }
}
