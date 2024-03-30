import 'package:flutter/material.dart';
import 'package:my_tv/common/index.dart';

class ListenGesture extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;
  final void Function()? onDoubleTap;
  final void Function()? onDragDown;
  final void Function()? onDragUp;

  const ListenGesture({super.key, required this.child, this.onTap, this.onDoubleTap, this.onDragDown, this.onDragUp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy > 0) {
          Global.logger.d("向下滑动");
          onDragDown?.call();
        } else if (details.velocity.pixelsPerSecond.dy < -0) {
          Global.logger.d("向上滑动");
          onDragUp?.call();
        }
      },
      child: child,
    );
  }
}
