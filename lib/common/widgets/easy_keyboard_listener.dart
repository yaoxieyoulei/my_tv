import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class EasyKeyboardListener extends KeyboardListener {
  final Map<LogicalKeyboardKey, void Function()>? onKeyTap;
  final Map<LogicalKeyboardKey, void Function()>? onKeyLongTap;

  const EasyKeyboardListener({
    super.key,
    required super.child,
    required super.focusNode,
    super.autofocus,
    super.includeSemantics,
    this.onKeyTap,
    this.onKeyLongTap,
  });

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
      focusNode: focusNode,
      autofocus: autofocus,
      includeSemantics: includeSemantics,
      child: child,
    );
  }
}
