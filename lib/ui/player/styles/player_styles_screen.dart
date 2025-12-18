// lib/ui/player/player_styles_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/player/styles/skin_preview.dart';
import 'package:vinu/ui/player/player_skin_controller.dart';
import 'package:vinu/ui/player/widgets/mini_artwork.dart';

/// Player styles screen with lightweight mini-previews for each skin.
/// Ensure the indices here match the order you supply in FullPlayer's `skins` list.
class PlayerStylesScreen extends StatelessWidget {
  const PlayerStylesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Keep entries in same order as FullPlayer.skins list
    final _skinEntries = [
      _SkinEntry(
        skin: PlayerSkinType.classic,
        name: 'Classic',
        builder: _previewClassic,
      ),
      _SkinEntry(
        skin: PlayerSkinType.minimal,
        name: 'Minimal',
        builder: _previewMinimal,
      ),
      _SkinEntry(
        skin: PlayerSkinType.circular,
        name: 'Circular',
        builder: _previewCircular,
      ),
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        title: Text(
          'Player styles',
          style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: _skinEntries.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (ctx, i) {
            final entry = _skinEntries[i];
            final skinCtrl = ctx.watch<PlayerSkinController>();
            final selected = skinCtrl.selectedSkin == entry.skin;

            return SkinPreview(
              name: entry.name,
              preview: entry.builder(ctx),
              selected: selected,
              onTap: () {
                ctx.read<PlayerSkinController>().setSkin(entry.skin);
                // short feedback
                ScaffoldMessenger.of(ctx).removeCurrentSnackBar();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Applied "${entry.name}"')),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ------------------------------
  // Preview builders (lightweight)
  // ------------------------------

  // Classic-ish preview: album artwork + small controls row
  static Widget _previewClassic(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: scheme.surfaceContainerHighest.withValues( alpha:0.06),
                child: Center(child: MiniArtwork(songId: 0, placeholder: _placeholderIcon(scheme))),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _miniControlsRow(scheme),
        ],
      ),
    );
  }

  // Minimal preview: big centered artwork with title band
  static Widget _previewMinimal(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: scheme.surfaceContainerHighest.withValues( alpha:0.05),
                  width: double.infinity,
                  child: const Center(child: Icon(Icons.music_note, size: 40)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _fakeTitleBand(scheme),
        ],
      ),
    );
  }
  static Widget _previewCircular(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular seek bar (fake progress)
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: 0.65, // preview-only fake progress
                      strokeWidth: 6,
                      backgroundColor:
                          scheme.onSurfaceVariant.withValues(alpha: 0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),

                  // Artwork
                  ClipOval(
                    child: Container(
                      width: 110,
                      height: 110,
                      color: scheme.surfaceContainerHighest
                          .withValues(alpha: 0.06),
                      child: const Icon(
                        Icons.music_note,
                        size: 42,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _fakeTitleBand(scheme),
        ],
      ),
    );
  }

  // -----------------------
  // Small helper widgets
  // -----------------------
  static Widget _miniControlsRow(ColorScheme scheme, {bool small = false}) {
    final iconSize = small ? 18.0 : 22.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.shuffle, size: iconSize, color: scheme.onSurfaceVariant),
        Icon(Icons.skip_previous, size: iconSize + 4, color: scheme.onSurface),
        Container(
          width: small ? 36 : 44,
          height: small ? 36 : 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary,
          ),
          child: Icon(Icons.play_arrow, color: scheme.onPrimary, size: small ? 18 : 24),
        ),
        Icon(Icons.skip_next, size: iconSize + 4, color: scheme.onSurface),
        Icon(Icons.queue_music, size: iconSize, color: scheme.onSurfaceVariant),
      ],
    );
  }

  static Widget _fakeTitleBand(ColorScheme scheme, {bool small = false}) {
    return Container(
      height: small ? 12 : 16,
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant.withValues( alpha:0.08),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  static Widget _placeholderIcon(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHigh,
      child: Icon(Icons.music_note, color: scheme.onSurfaceVariant),
    );
  }
}

// tiny helper entry type
class _SkinEntry {
  final PlayerSkinType skin;
  final String name;
  final Widget Function(BuildContext) builder;

  const _SkinEntry({
    required this.skin,
    required this.name,
    required this.builder,
  });
}

