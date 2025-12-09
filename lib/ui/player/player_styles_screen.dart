// lib/ui/player/player_styles_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/player/skin_preview.dart';
import 'package:vinu/ui/player/player_skin_controller.dart';
import 'package:vinu/ui/player/mini_artwork.dart';

/// Player styles screen with lightweight mini-previews for each skin.
/// Ensure the indices here match the order you supply in FullPlayer's `skins` list.
class PlayerStylesScreen extends StatelessWidget {
  const PlayerStylesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Keep entries in same order as FullPlayer.skins list
    final _skinEntries = <_SkinEntry>[
      _SkinEntry(index: 0, name: 'Classic', builder: (ctx) => _previewClassic(ctx)),
      _SkinEntry(index: 1, name: 'Minimal', builder: (ctx) => _previewMinimal(ctx)),
      _SkinEntry(index: 2, name: 'Minimal Pro', builder: (ctx) => _previewMinimalPro(ctx)),
      _SkinEntry(index: 3, name: 'Neon Glow', builder: (ctx) => _previewNeon(ctx)),
      _SkinEntry(index: 4, name: 'Retro Tape', builder: (ctx) => _previewRetro(ctx)),
      _SkinEntry(index: 5, name: 'Glassy', builder: (ctx) => _previewGlassy(ctx)),
      _SkinEntry(index: 6, name: 'Vinyl Ultra', builder: (ctx) => _previewVinyl(ctx)),
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
            final selected = skinCtrl.selectedSkin == entry.index;

            return SkinPreview(
              name: entry.name,
              preview: entry.builder(ctx),
              selected: selected,
              onTap: () {
                ctx.read<PlayerSkinController>().setSkin(entry.index);
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

  // Minimal Pro preview: artwork left + small seek + controls
  static Widget _previewMinimalPro(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 72, height: 72, child: MiniArtwork(songId: 0, placeholder: _placeholderIcon(scheme))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                _fakeTitleBand(scheme, small: true),
                const SizedBox(height: 8),
                _fakeTinySeek(scheme),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: _miniPlayIcon(scheme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Neon preview: colorful background with glowing circle + controls
  static Widget _previewNeon(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [scheme.primary.withValues( alpha:0.12), scheme.secondary.withValues( alpha:0.04)]),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: RadialGradient(colors: [scheme.primary.withValues( alpha:0.15), Colors.transparent]),
                ),
                child: const Center(child: Icon(Icons.music_note, size: 44)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _miniControlsRow(scheme, small: true),
        ],
      ),
    );
  }

  // Retro tape preview: textured rectangle + faux reels
  static Widget _previewRetro(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      color: scheme.surface,
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues( alpha:0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tinyReel(scheme),
                  _tinyReel(scheme),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _miniControlsRow(scheme, small: true),
        ],
      ),
    );
  }

  // Glassy preview: frosted band + artwork
  static Widget _previewGlassy(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: scheme.surface,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: scheme.surfaceContainerHighest.withValues( alpha:0.04),
              ),
              child: const Center(child: Icon(Icons.music_video_rounded, size: 40)),
            ),
          ),
          const SizedBox(height: 8),
          _fakeTitleBand(scheme, small: true),
        ],
      ),
    );
  }

  // Vinyl ultra preview: circular artwork + small ring
  static Widget _previewVinyl(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      color: scheme.surface,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [scheme.primary.withValues( alpha:0.08), Colors.transparent]),
                ),
                child: const Center(child: Icon(Icons.album_rounded, size: 48)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _miniControlsRow(scheme, small: true),
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

  static Widget _fakeTinySeek(ColorScheme scheme) {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant.withValues( alpha:0.06),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  static Widget _tinyReel(ColorScheme scheme) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surfaceContainerHighest.withValues( alpha:0.06),
        border: Border.all(color: scheme.onSurfaceVariant.withValues( alpha:0.07)),
      ),
      child: Center(child: Icon(Icons.circle, size: 10, color: scheme.onSurfaceVariant)),
    );
  }

  static Widget _miniPlayIcon(ColorScheme scheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
      child: Icon(Icons.play_arrow, color: scheme.onPrimary, size: 18),
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
  final int index;
  final String name;
  final Widget Function(BuildContext) builder;
  const _SkinEntry({required this.index, required this.name, required this.builder});
}
