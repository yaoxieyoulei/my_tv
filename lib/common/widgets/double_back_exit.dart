import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DoubleBackExit extends StatefulWidget {
  final Widget child;

  const DoubleBackExit({super.key, required this.child});

  @override
  DoubleBackExitState createState() {
    return DoubleBackExitState();
  }
}

class DoubleBackExitState extends State<DoubleBackExit> {
  DateTime? _lastPressedAt; //上次点击时间

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        } else {
          if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 1)) {
            //两次点击间隔超过1秒则重新计时
            _lastPressedAt = DateTime.now();
            Fluttertoast.showToast(msg: "再按一次退出", gravity: ToastGravity.TOP);
            return;
          }

          SystemNavigator.pop();
        }
      },
      child: widget.child,
    );
  }
}
