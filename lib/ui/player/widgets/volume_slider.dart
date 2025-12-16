import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();

    // Get initial device volume
    VolumeController().getVolume().then((v) {
      setState(() => _volume = v);
    });

    // Listen live to device volume button changes
    VolumeController().listener((v) {
      if (mounted) setState(() => _volume = v);
    });
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: scheme.surface.withValues( alpha:0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.volume_up_rounded, color: scheme.primary, size: 32),
          const SizedBox(height: 12),

          Slider(
            min: 0.0,
            max: 1.0,
            value: _volume,
            activeColor: scheme.primary,
            thumbColor: scheme.primary,
            onChanged: (v) {
              setState(() => _volume = v);
              VolumeController().setVolume(v, showSystemUI: false);
            },
          ),
        ],
      ),
    );
  }
}
