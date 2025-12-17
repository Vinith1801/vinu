import 'package:flutter/material.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onSelected;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onSelected,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text('Pick accent color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color preview
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _hsv.toColor(),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),

          _slider(
            label: 'Color',
            value: _hsv.hue,
            max: 360,
            onChanged: (v) => setState(() => _hsv = _hsv.withHue(v)),
          ),

          _slider(
            label: 'Intensity',
            value: _hsv.saturation,
            max: 1,
            onChanged: (v) => setState(() => _hsv = _hsv.withSaturation(v)),
          ),

          _slider(
            label: 'Brightness',
            value: _hsv.value,
            max: 1,
            onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('Apply'),
          onPressed: () {
            widget.onSelected(_hsv.toColor());
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Slider(
          value: value,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
