import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

extension FPS on Duration {
  double get fps => (1000 / inMilliseconds);
}

/// 显示FPS
class ShowFPS extends StatefulWidget {
  final Widget child;
  final bool visible;

  const ShowFPS({super.key, required this.child, required this.visible});

  @override
  State<ShowFPS> createState() => _ShowFPSState();
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
    if (!mounted || !widget.visible) {
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
  void didUpdateWidget(covariant ShowFPS oldWidget) {
    if (oldWidget.visible && !widget.visible) {
      previous = null;
    }

    if (!oldWidget.visible && widget.visible) {
      SchedulerBinding.instance.addPostFrameCallback(update);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        widget.child,
        if (widget.visible)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: chartHeight,
              width: chartWidth + 17,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (timings.isNotEmpty)
                    Text(
                      'FPS: ${getAvgFPS()}',
                      style: const TextStyle(
                        color: Color(0xffffffff),
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
      ],
    );
  }
}
