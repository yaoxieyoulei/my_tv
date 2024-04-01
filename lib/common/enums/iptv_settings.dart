import 'package:my_tv/common/index.dart';

/// 直播设置
enum IPTVSetting {
  /// 初始直播源序号
  initialIPTVIdx,

  /// 换台反转
  channelChangeFlip,

  /// 直播源类型
  iptvType,

  /// 直播源缓存时间
  iptvCacheTime,
}

/// 直播源类型
enum IPTVSettingIPTVType {
  /// 完整
  full,

  /// 精简
  simple,
}

extension IPTVSettingIPTVTypeExtension on IPTVSettingIPTVType {
  String get name {
    switch (this) {
      case IPTVSettingIPTVType.full:
        return '完整';
      case IPTVSettingIPTVType.simple:
        return '精简';
    }
  }
}

/// 直播设置
class IPTVSettings {
  static int get initialIPTVIdx => Global.prefs.getInt(IPTVSetting.initialIPTVIdx.toString()) ?? 0;
  static set initialIPTVIdx(int value) => Global.prefs.setInt(IPTVSetting.initialIPTVIdx.toString(), value);

  static bool get channelChangeFlip => Global.prefs.getBool(IPTVSetting.channelChangeFlip.toString()) ?? false;
  static set channelChangeFlip(bool value) => Global.prefs.setBool(IPTVSetting.channelChangeFlip.toString(), value);

  static IPTVSettingIPTVType get iptvType =>
      IPTVSettingIPTVType.values[Global.prefs.getInt(IPTVSetting.iptvType.toString()) ?? 0];
  static set iptvType(IPTVSettingIPTVType value) => Global.prefs.setInt(IPTVSetting.iptvType.toString(), value.index);

  static int get iptvCacheTime => Global.prefs.getInt(IPTVSetting.iptvCacheTime.toString()) ?? 0;
  static set iptvCacheTime(int value) => Global.prefs.setInt(IPTVSetting.iptvCacheTime.toString(), value);
}
