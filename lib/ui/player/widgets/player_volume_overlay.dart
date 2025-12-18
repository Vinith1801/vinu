import 'package:flutter/material.dart';
import 'volume_slider.dart';

class PlayerVolumeOverlay extends StatelessWidget {
  final bool visible;
  final VoidCallback onDismiss;

  const PlayerVolumeOverlay({
    super.key,
    required this.visible,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        onVerticalDragEnd: (_) => onDismiss(),
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: const Center(
            child: VolumeSlider(),
          ),
        ),
      ),
    );
  }
}
