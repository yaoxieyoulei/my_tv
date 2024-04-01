import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_tv/common/index.dart';

class DirectionGestureDetector extends StatelessWidget {
  DirectionGestureDetector({
    super.key,
    required this.child,
    this.onDragUp,
    this.onDragDown,
    this.onDragLeft,
    this.onDragRight,
  });

  final Widget child;
  final void Function()? onDragUp;
  final void Function()? onDragDown;
  final void Function()? onDragLeft;
  final void Function()? onDragRight;

  final _verticalTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
  final _horizontalTracker = VelocityTracker.withKind(PointerDeviceKind.touch);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        if (details.sourceTimeStamp != null) {
          _verticalTracker.addPosition(details.sourceTimeStamp!, details.globalPosition);
        }
      },
      onVerticalDragUpdate: (details) {
        if (details.sourceTimeStamp != null) {
          _verticalTracker.addPosition(details.sourceTimeStamp!, details.globalPosition);
        }
      },
      onVerticalDragEnd: (details) {
        if (_verticalTracker.getVelocity().pixelsPerSecond.dy > 100) {
          Global.logger.d('[滑动] 向下滑动');
          onDragDown?.call();
        } else if (_verticalTracker.getVelocity().pixelsPerSecond.dy < -100) {
          Global.logger.d('[滑动] 向上滑动');
          onDragUp?.call();
        }
      },
      onHorizontalDragStart: (details) {
        if (details.sourceTimeStamp != null) {
          _horizontalTracker.addPosition(details.sourceTimeStamp!, details.globalPosition);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (details.sourceTimeStamp != null) {
          _horizontalTracker.addPosition(details.sourceTimeStamp!, details.globalPosition);
        }
      },
      onHorizontalDragEnd: (details) {
        if (_horizontalTracker.getVelocity().pixelsPerSecond.dx > 100) {
          Global.logger.d('[滑动] 向左滑动');
          onDragLeft?.call();
        } else if (_horizontalTracker.getVelocity().pixelsPerSecond.dx < -100) {
          Global.logger.d('[滑动] 向右滑动');
          onDragRight?.call();
        }
      },
      child: child,
    );
  }
}