import 'package:flutter/material.dart';

class DelayRenderer extends StatefulWidget {
  const DelayRenderer({
    super.key,
    required this.child,
    required this.delayFrame,
    this.placeholder,
  });

  final Widget child;
  final int delayFrame;
  final Widget? placeholder;

  @override
  State<DelayRenderer> createState() => _DelayRendererState();
}

class _DelayRendererState extends State<DelayRenderer> {
  late var _visible = widget.delayFrame <= 0;

  void _init() {
    if (widget.delayFrame <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 16 * widget.delayFrame), () {
        if (mounted) {
          setState(() {
            _visible = true;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return _visible ? widget.child : (widget.placeholder ?? Container());
  }
}

extension DelayRendererExtension on Widget {
  Widget delayed(int delayFrame, {Widget? placeholder}) {
    return DelayRenderer(
      delayFrame: delayFrame,
      placeholder: placeholder,
      child: this,
    );
  }
}

extension DelayRendererListExtension on List<Widget> {
  List<Widget> delayed({List<Widget?>? placeholder}) {
    return indexed
        .map((it) => (it.$2).delayed(
              it.$1,
              placeholder: placeholder?.elementAt(it.$1),
            ))
        .toList();
  }
}
