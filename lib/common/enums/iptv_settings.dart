import 'package:my_tv/common/index.dart';

/// 直播设置
enum IPTVSetting {
  /// 开机自启
  bootLaunch,

  /// 初始直播源序号
  initialIPTVIdx,

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
  static bool get bootLaunch => Global.prefs.getBool(IPTVSetting.bootLaunch.toString()) ?? false;
  static set bootLaunch(bool value) => Global.prefs.setBool(IPTVSetting.bootLaunch.toString(), value);

  static int get initialIPTVIdx => Global.prefs.getInt(IPTVSetting.initialIPTVIdx.toString()) ?? 0;
  static set initialIPTVIdx(int value) => Global.prefs.setInt(IPTVSetting.initialIPTVIdx.toString(), value);

  static bool get channelChangeFlip => Global.prefs.getBool(IPTVSetting.channelChangeFlip.toString()) ?? false;
  static set channelChangeFlip(bool value) => Global.prefs.setBool(IPTVSetting.channelChangeFlip.toString(), value);

  static bool get smoothChangeChannel => Global.prefs.getBool(IPTVSetting.smoothChangeChannel.toString()) ?? false;
  static set smoothChangeChannel(bool value) => Global.prefs.setBool(IPTVSetting.smoothChangeChannel.toString(), value);

  static IPTVSettingIPTVType get iptvType =>
      IPTVSettingIPTVType.values[Global.prefs.getInt(IPTVSetting.iptvType.toString()) ?? 0];
  static set iptvType(IPTVSettingIPTVType value) => Global.prefs.setInt(IPTVSetting.iptvType.toString(), value.index);

  static int get iptvCacheTime => Global.prefs.getInt(IPTVSetting.iptvCacheTime.toString()) ?? 0;
  static set iptvCacheTime(int value) => Global.prefs.setInt(IPTVSetting.iptvCacheTime.toString(), value);

  static String get customIptvM3u => Global.prefs.getString(IPTVSetting.customIptvM3u.toString()) ?? '';
  static set customIptvM3u(String value) => Global.prefs.setString(IPTVSetting.customIptvM3u.toString(), value);

  static bool get epgEnable => Global.prefs.getBool(IPTVSetting.epgEnable.toString()) ?? true;
  static set epgEnable(bool value) => Global.prefs.setBool(IPTVSetting.epgEnable.toString(), value);

  static int get epgXmlCacheTime => Global.prefs.getInt(IPTVSetting.epgXmlCacheTime.toString()) ?? 0;
  static set epgXmlCacheTime(int value) => Global.prefs.setInt(IPTVSetting.epgXmlCacheTime.toString(), value);

  static int get epgCacheHash => Global.prefs.getInt(IPTVSetting.epgCacheHash.toString()) ?? 0;
  static set epgCacheHash(int value) => Global.prefs.setInt(IPTVSetting.epgCacheHash.toString(), value);
}
