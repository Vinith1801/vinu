import 'dart:async';
import '../../core/audio/audio_engine.dart';

class PositionData {
  final Duration position;
  final Duration buffered;
  final Duration duration;

  PositionData(this.position, this.buffered, this.duration);
}

class PositionController {
  final AudioEngine engine;

  final _ctrl = StreamController<PositionData>.broadcast();
  Duration _p = Duration.zero;
  Duration _b = Duration.zero;
  Duration _d = Duration.zero;

  PositionController(this.engine) {
    engine.player.positionStream.listen((v) {
      _p = v;
      _emit();
    });

    engine.player.bufferedPositionStream.listen((v) {
      _b = v;
      _emit();
    });

    engine.player.durationStream.listen((v) {
      _d = v ?? Duration.zero;
      _emit();
    });
  }

  void _emit() {
    _ctrl.add(PositionData(_p, _b, _d));
  }

  Stream<PositionData> get raw => _ctrl.stream;

  Stream<PositionData> get smooth =>
      _ctrl.stream.transform(_throttle(const Duration(milliseconds: 120)));

  StreamTransformer<T, T> _throttle<T>(Duration d) {
    return StreamTransformer.fromBind((s) {
      bool canEmit = true;
      return s.where((_) {
        if (!canEmit) return false;
        canEmit = false;
        Future.delayed(d, () => canEmit = true);
        return true;
      });
    });
  }

  void dispose() {
    _ctrl.close();
  }
}
