import 'dart:math';
import 'package:flutter/material.dart';

class CircularSeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final double size;
  final double strokeWidth;

  const CircularSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.size = 300,
    this.strokeWidth = 6,
  });

  @override
  State<CircularSeekBar> createState() => _CircularSeekBarState();
}

class _CircularSeekBarState extends State<CircularSeekBar> {
  double _progress = 0;

  @override
  void didUpdateWidget(covariant CircularSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration.inMilliseconds > 0) {
      _progress = widget.position.inMilliseconds /
          widget.duration.inMilliseconds;
    }
  }

  bool _isTouchOnRing(Offset local, Size size) {
    final center = size.center(Offset.zero);
    final distance = (local - center).distance;
    final radius = size.width / 2;

    // Accept touches only near the ring
    const tolerance = 14.0;
    return (distance >= radius - tolerance &&
        distance <= radius + tolerance);
  }

  void _handleSeek(Offset localPosition, Size size) {
    final center = size.center(Offset.zero);
    final angle =
        atan2(localPosition.dy - center.dy, localPosition.dx - center.dx);

    final normalized = (angle + pi / 2) / (2 * pi);
    final progress = normalized < 0 ? normalized + 1 : normalized;

    final clamped = progress.clamp(0.0, 1.0);
    widget.onSeek(widget.duration * clamped);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = Size.square(widget.size);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        if (_isTouchOnRing(e.localPosition, size)) {
          _handleSeek(e.localPosition, size);
        }
      },
      onPointerMove: (e) {
        if (_isTouchOnRing(e.localPosition, size)) {
          _handleSeek(e.localPosition, size);
        }
      },
      child: CustomPaint(
        size: size,
        painter: _CircularSeekPainter(
          progress: _progress,
          color: scheme.primary,
          background: scheme.onSurfaceVariant.withValues(alpha : 0.3),
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}

class _CircularSeekPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color background;
  final double strokeWidth;

  _CircularSeekPainter({
    required this.progress,
    required this.color,
    required this.background,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularSeekPainter old) =>
      old.progress != progress;
}
