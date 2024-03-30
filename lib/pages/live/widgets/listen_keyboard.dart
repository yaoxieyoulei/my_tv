import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tv/common/index.dart';

class ListenKeyboard extends StatelessWidget {
  final Widget child;
  final void Function()? onKeyArrowUp;
  final void Function()? onKeyArrowDown;
  final void Function()? onKeyArrowLeft;
  final void Function()? onKeyArrowRight;
  final void Function()? onKeySelect;
  final void Function()? onKeyGoBack;
  final void Function(int digit)? onKeyDigit;
  final void Function()? onKeySettings;

  final _focusNode = FocusNode();

  ListenKeyboard(
      {super.key,
      required this.child,
      this.onKeyArrowUp,
      this.onKeyArrowDown,
      this.onKeyArrowLeft,
      this.onKeyArrowRight,
      this.onKeySelect,
      this.onKeyGoBack,
      this.onKeyDigit,
      this.onKeySettings}) {
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        // 只有按键抬起时触发
        if (event.runtimeType != KeyUpEvent) return;

        Global.logger.d(event.logicalKey);

        // 向下键
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          onKeyArrowUp?.call();
        }
        // 向上键
        else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          onKeyArrowDown?.call();
        }
        // 向左键
        else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          onKeyArrowLeft?.call();
        }
        // 向右键
        else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          onKeyArrowRight?.call();
        }
        // OK键
        else if (event.logicalKey == LogicalKeyboardKey.select) {
          onKeySelect?.call();
        }
        // 返回键
        else if (event.logicalKey == LogicalKeyboardKey.goBack) {
          onKeyGoBack?.call();
        }
        // 数字键
        else if (event.logicalKey == LogicalKeyboardKey.digit1) {
          onKeyDigit?.call(1);
        } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
          onKeyDigit?.call(2);
        } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
          onKeyDigit?.call(3);
        } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
          onKeyDigit?.call(4);
        } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
          onKeyDigit?.call(5);
        } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
          onKeyDigit?.call(6);
        } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
          onKeyDigit?.call(7);
        } else if (event.logicalKey == LogicalKeyboardKey.digit8) {
          onKeyDigit?.call(8);
        } else if (event.logicalKey == LogicalKeyboardKey.digit9) {
          onKeyDigit?.call(9);
        } else if (event.logicalKey == LogicalKeyboardKey.digit0) {
          onKeyDigit?.call(0);
        } else if ([
          LogicalKeyboardKey.settings,
          LogicalKeyboardKey.contextMenu,
          LogicalKeyboardKey.help,
        ].any((it) => it == event.logicalKey)) {
          onKeySettings?.call();
        }
      },
      child: child,
    );
  }
}
