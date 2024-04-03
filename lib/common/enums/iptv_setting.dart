import 'package:my_tv/common/index.dart';

/// 直播设置
enum IptvSetting {
  /// 初始直播源序号
  initialIptvIdx,

  /// 换台反转
  channelChangeFlip,

  /// 直播源精简
  iptvSourceSimplify,

  /// 直播源缓存时间
  iptvSourceCacheTime,

  /// 自定义直播源
  customIptvSource,

  /// 启用epg
  epgEnable,

  /// epg缓存时间
  epgXmlCacheTime,

  /// epg解析缓存hash
  epgCacheHash,
}

/// 直播设置
class IptvSettings {
  IptvSettings._();

  static int get initialIptvIdx => PrefsUtil.getInt(IptvSetting.initialIptvIdx.toString()) ?? 0;
  static set initialIptvIdx(int value) => PrefsUtil.setInt(IptvSetting.initialIptvIdx.toString(), value);

  static bool get channelChangeFlip => PrefsUtil.getBool(IptvSetting.channelChangeFlip.toString()) ?? false;
  static set channelChangeFlip(bool value) => PrefsUtil.setBool(IptvSetting.channelChangeFlip.toString(), value);

  static bool get iptvSourceSimplify => PrefsUtil.getBool(IptvSetting.iptvSourceSimplify.toString()) ?? false;
  static set iptvSourceSimplify(bool value) => PrefsUtil.setBool(IptvSetting.iptvSourceSimplify.toString(), value);

  static int get iptvSourceCacheTime => PrefsUtil.getInt(IptvSetting.iptvSourceCacheTime.toString()) ?? 0;
  static set iptvSourceCacheTime(int value) => PrefsUtil.setInt(IptvSetting.iptvSourceCacheTime.toString(), value);

  static String get customIptvSource => PrefsUtil.getString(IptvSetting.customIptvSource.toString()) ?? '';
  static set customIptvSource(String value) => PrefsUtil.setString(IptvSetting.customIptvSource.toString(), value);

  static bool get epgEnable => PrefsUtil.getBool(IptvSetting.epgEnable.toString()) ?? true;
  static set epgEnable(bool value) => PrefsUtil.setBool(IptvSetting.epgEnable.toString(), value);

  static int get epgXmlCacheTime => PrefsUtil.getInt(IptvSetting.epgXmlCacheTime.toString()) ?? 0;
  static set epgXmlCacheTime(int value) => PrefsUtil.setInt(IptvSetting.epgXmlCacheTime.toString(), value);

  static int get epgCacheHash => PrefsUtil.getInt(IptvSetting.epgCacheHash.toString()) ?? 0;
  static set epgCacheHash(int value) => PrefsUtil.setInt(IptvSetting.epgCacheHash.toString(), value);
}
