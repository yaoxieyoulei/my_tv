/// 常量
class Constants {
  /// 直播源
  static const iptvSource = 'https://mirror.ghproxy.com/https://raw.githubusercontent.com/zhumeng11/IPTV/main/IPTV.m3u';

  /// 直播源缓存时间
  static const iptvSourceCacheTime = 1000 * 60 * 60 * 24; // 24小时

  /// epg xml
  static const iptvEpgXml = 'https://live.fanmingming.com/e.xml';

  /// epg 刷新时间阈值（小时）
  ///
  /// 不到这个时间点不刷新
  static const epgRefreshTimeThreshold = 2; // 不到2点不刷新

  /// github release latest
  static const githubReleaseLatest = 'https://api.github.com/repos/yaoxieyoulei/my_tv/releases/latest';

  /// 设置服务器端口
  static const httpServerPort = 10381;

  /// http请求重试次数
  static const httpRetryCount = 10;

  /// HTTP请求重试间隔时间（毫秒）
  static const httpRetryInterval = 3000;
}
