import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../player/audio_player_controller.dart';

class PlayerArtworkSurface extends StatefulWidget {
  final Widget artwork;
  final BorderRadius? borderRadius;

  const PlayerArtworkSurface({
    super.key,
    required this.artwork,
    this.borderRadius,
  });

  @override
  State<PlayerArtworkSurface> createState() => _PlayerArtworkSurfaceState();
}

class _PlayerArtworkSurfaceState extends State<PlayerArtworkSurface>
    with SingleTickerProviderStateMixin {
  static const double _swipeThreshold = 120;
  static const double _maxScaleReduction = 0.06; // 6%

  late final AnimationController _animCtrl;
  late Animation<double> _anim;

  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _animateTo(double target, {VoidCallback? onComplete}) {
    _anim = Tween<double>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _animCtrl
      ..reset()
      ..forward();

    void listener() {
      setState(() {
        _dragOffset = _anim.value;
      });
    }

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _animCtrl.removeListener(listener);
        _animCtrl.removeStatusListener(statusListener);
        onComplete?.call();
      }
    }

    _animCtrl.addListener(listener);
    _animCtrl.addStatusListener(statusListener);
  }

  double _currentScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final progress = (_dragOffset.abs() / width).clamp(0.0, 1.0);
    return 1.0 - (_maxScaleReduction * progress);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AudioPlayerController>();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dx;
        });
      },

      onHorizontalDragEnd: (_) {
        if (_dragOffset <= -_swipeThreshold) {
          // swipe left → next
          _animateTo(-MediaQuery.of(context).size.width, onComplete: () {
            controller.next();
            setState(() => _dragOffset = 0);
          });
        } else if (_dragOffset >= _swipeThreshold) {
          // swipe right → previous
          _animateTo(MediaQuery.of(context).size.width, onComplete: () {
            controller.previous();
            setState(() => _dragOffset = 0);
          });
        } else {
          // snap back
          _animateTo(0);
        }
      },

      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: Transform.scale(
          scale: _currentScale(context),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: widget.artwork,
          ),
        ),
      ),
    );
  }
}
