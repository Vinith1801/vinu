import 'package:flutter/material.dart';

class SeekBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onChangeEnd;

  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final pos = position.inMilliseconds.toDouble();
    final dur = duration.inMilliseconds.toDouble();
    final sliderValue = pos.clamp(0, dur > 0 ? dur : 1).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,

            // THEMED TRACK COLORS
            activeTrackColor: scheme.primary,
            inactiveTrackColor: scheme.onSurfaceVariant.withValues(alpha: 0.3),

            // THEMED THUMB
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            thumbColor: scheme.primary,

            // THEMED OVERLAY
            overlayColor: scheme.primary.withValues(alpha: 0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),

            // Remove value indicator for clean music player UI
            valueIndicatorColor: Colors.transparent,
            valueIndicatorTextStyle: const TextStyle(fontSize: 0),
          ),
          child: Slider(
            min: 0,
            max: dur > 0 ? dur : 1,
            value: sliderValue,
            onChanged: (_) {},
            onChangeEnd: (value) =>
                onChangeEnd(Duration(milliseconds: value.toInt())),
          ),
        ),

        // TIME LABELS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(position),
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _format(duration),
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
