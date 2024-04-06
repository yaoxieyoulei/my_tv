import 'package:my_tv/common/index.dart';

/// 调试设置
enum DebugSetting {
  /// 列表延时渲染
  listDelayRender,
}

/// 调试设置
class DebugSettings {
  DebugSettings._();

  static bool get listDelayRender => PrefsUtil.getBool(DebugSetting.listDelayRender.toString()) ?? false;
  static set listDelayRender(bool value) => PrefsUtil.setBool(DebugSetting.listDelayRender.toString(), value);
}
