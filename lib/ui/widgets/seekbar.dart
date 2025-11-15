import 'package:flutter/material.dart';

class SeekBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onChangeEnd;

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

    return Column(
      children: [
        Slider(
          min: 0,
          max: dur,
          value: pos.clamp(0, dur),
          onChanged: (_) {},
          onChangeEnd: (value) =>
              onChangeEnd(Duration(milliseconds: value.toInt())),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(position)),
              Text(_format(duration)),
            ],
          ),
        )
      ],
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
