import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

extension FPS on Duration {
  double get fps => (1000 / inMilliseconds);
}

/// 显示FPS
class ShowFPS extends StatefulWidget {
  const ShowFPS({super.key});

  @override
  State<ShowFPS> createState() => _ShowFPSState();

  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    _entry = OverlayEntry(builder: (context) => const ShowFPS());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(_entry!);
    });
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  static void toggle(BuildContext context) {
    if (_entry == null) {
      show(context);
    } else {
      hide();
    }
  }

  static bool get isShowing => _entry != null;
}

class _ShowFPSState extends State<ShowFPS> {
  Duration? previous;
  List<Duration> timings = [];
  double chartWidth = 150;
  double chartHeight = 80;
  late int framesToDisplay = chartWidth ~/ 5;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(update);
    super.initState();
  }

  update(Duration duration) {
    if (!mounted) {
      return;
    }

    setState(() {
      if (previous != null) {
        timings.add(duration - previous!);
        if (timings.length > framesToDisplay) {
          timings = timings.sublist(timings.length - framesToDisplay - 1);
        }
      }

      previous = duration;
    });

    SchedulerBinding.instance.addPostFrameCallback(update);
  }

  int getAvgFPS() {
    final t = timings.fold(0.0, (value, element) => value + element.fps);

    if (t.isNaN || t.isInfinite) return 0;

    return (t / timings.length).round();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          height: chartHeight,
          width: chartWidth + 17,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background.withOpacity(0.8),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (timings.isNotEmpty)
                Text(
                  'FPS: ${getAvgFPS()}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 4),
              Expanded(
                child: SizedBox(
                  width: chartWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ...timings.map((timing) {
                        final p = (timing.fps / 60).clamp(0.0, 1.0);

                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 1.0,
                          ),
                          child: Container(
                            width: 4,
                            height: p * chartHeight,
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                const Color(0xfff44336),
                                const Color.fromARGB(255, 0, 162, 255),
                                p,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
