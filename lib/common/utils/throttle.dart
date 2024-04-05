import 'dart:async';

class Throttle {
  late final Duration _duration;

  Throttle({Duration duration = const Duration(seconds: 1)}) : _duration = duration;

  Timer? _timer;

  void throttle(Function action) {
    if (_timer == null || !_timer!.isActive) {
      action();
      _timer = Timer(_duration, () => _timer?.cancel());
    }
  }
}
