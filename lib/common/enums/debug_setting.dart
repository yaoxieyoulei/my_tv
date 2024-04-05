import 'package:my_tv/common/index.dart';

/// 调试设置
enum DebugSetting {
  /// 显示FPS
  showFPS,
}

/// 调试设置
class DebugSettings {
  DebugSettings._();

  static bool get showFPS => PrefsUtil.getBool(DebugSetting.showFPS.toString()) ?? false;
  static set showFPS(bool value) => PrefsUtil.setBool(DebugSetting.showFPS.toString(), value);
}
