import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class EasyKeyboardListener extends StatelessWidget {
  const EasyKeyboardListener({
    super.key,
    required this.child,
    this.focusNode,
    this.onKeyTap,
    this.onKeyLongTap,
    this.autofocus = false,
  });

  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;
  final Map<LogicalKeyboardKey, void Function()>? onKeyTap;
  final Map<LogicalKeyboardKey, void Function()>? onKeyLongTap;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (event) {
        if (event.runtimeType == KeyUpEvent) {
          final key = event.logicalKey;

          if (onKeyTap?.containsKey(key) == true) {
            onKeyTap![key]!();
          }
        }

        if (event.runtimeType == KeyRepeatEvent) {
          final key = event.logicalKey;

          if (onKeyLongTap?.containsKey(key) == true) {
            onKeyLongTap![key]!();
          }
        }
      },
      focusNode: focusNode ?? FocusNode(),
      autofocus: autofocus,
      child: child,
    );
  }
}
