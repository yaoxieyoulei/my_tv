import 'package:my_tv/common/index.dart';

/// 直播设置
enum IptvSetting {
  /// 开机自启
  bootLaunch,

  /// 初始直播源序号
  initialIptvIdx,

  /// 换台反转
  channelChangeFlip,

  /// 平滑换台
  smoothChangeChannel,

  /// 直播源类型
  iptvType,

  /// 直播源缓存时间
  iptvCacheTime,

  /// 自定义直播源
  customIptvM3u,

  /// 启用epg
  epgEnable,

  /// epg缓存时间
  epgXmlCacheTime,

  /// epg解析hash
  epgCacheHash,
}

/// 直播源类型
enum IptvSettingIptvType {
  /// 完整
  full,

  /// 精简
  simple,
}

extension IptvSettingIptvTypeExtension on IptvSettingIptvType {
  String get name {
    switch (this) {
      case IptvSettingIptvType.full:
        return '完整';
      case IptvSettingIptvType.simple:
        return '精简';
    }
  }
}

/// 直播设置
class IptvSettings {
  static bool get bootLaunch => Global.prefs.getBool(IptvSetting.bootLaunch.toString()) ?? false;
  static set bootLaunch(bool value) => Global.prefs.setBool(IptvSetting.bootLaunch.toString(), value);

  static int get initialIptvIdx => Global.prefs.getInt(IptvSetting.initialIptvIdx.toString()) ?? 0;
  static set initialIptvIdx(int value) => Global.prefs.setInt(IptvSetting.initialIptvIdx.toString(), value);

  static bool get channelChangeFlip => Global.prefs.getBool(IptvSetting.channelChangeFlip.toString()) ?? false;
  static set channelChangeFlip(bool value) => Global.prefs.setBool(IptvSetting.channelChangeFlip.toString(), value);

  static bool get smoothChangeChannel => Global.prefs.getBool(IptvSetting.smoothChangeChannel.toString()) ?? false;
  static set smoothChangeChannel(bool value) => Global.prefs.setBool(IptvSetting.smoothChangeChannel.toString(), value);

  static IptvSettingIptvType get iptvType =>
      IptvSettingIptvType.values[Global.prefs.getInt(IptvSetting.iptvType.toString()) ?? 0];
  static set iptvType(IptvSettingIptvType value) => Global.prefs.setInt(IptvSetting.iptvType.toString(), value.index);

  static int get iptvCacheTime => Global.prefs.getInt(IptvSetting.iptvCacheTime.toString()) ?? 0;
  static set iptvCacheTime(int value) => Global.prefs.setInt(IptvSetting.iptvCacheTime.toString(), value);

  static String get customIptvM3u => Global.prefs.getString(IptvSetting.customIptvM3u.toString()) ?? '';
  static set customIptvM3u(String value) => Global.prefs.setString(IptvSetting.customIptvM3u.toString(), value);

  static bool get epgEnable => Global.prefs.getBool(IptvSetting.epgEnable.toString()) ?? true;
  static set epgEnable(bool value) => Global.prefs.setBool(IptvSetting.epgEnable.toString(), value);

  static int get epgXmlCacheTime => Global.prefs.getInt(IptvSetting.epgXmlCacheTime.toString()) ?? 0;
  static set epgXmlCacheTime(int value) => Global.prefs.setInt(IptvSetting.epgXmlCacheTime.toString(), value);

  static int get epgCacheHash => Global.prefs.getInt(IptvSetting.epgCacheHash.toString()) ?? 0;
  static set epgCacheHash(int value) => Global.prefs.setInt(IptvSetting.epgCacheHash.toString(), value);
}
