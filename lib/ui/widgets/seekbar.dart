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
    final pos = position.inMilliseconds.toDouble();
    final dur = duration.inMilliseconds.toDouble();

    final theme = Theme.of(context);
    final sliderValue = pos.clamp(0, dur).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            inactiveTrackColor: Colors.grey.shade300,
            activeTrackColor: theme.colorScheme.primary,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withOpacity(0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
                min: 0,
                max: dur > 0 ? dur : 1,
                value: sliderValue,
                onChanged: (_) {},
                onChangeEnd: (value) =>
                    onChangeEnd(Duration(milliseconds: value.toInt())),
              )
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(position),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _format(duration),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
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
