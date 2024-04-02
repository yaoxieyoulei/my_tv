import 'dart:io';

import 'package:my_tv/common/index.dart';
import 'package:path_provider/path_provider.dart';

/// Iptv工具类
class IptvUtil {
  /// 获取远程m3u
  static Future<String> _fetchM3u() async {
    final iptvM3u = IptvSettings.customIptvM3u.isNotEmpty ? IptvSettings.customIptvM3u : Constants.iptvM3u;

    Global.logger.debug('[iptv] 获取远程m3u: $iptvM3u');

    final response = await Global.dio.get(iptvM3u);
    if (response.statusCode != 200) {
      final err = '[iptv] 获取远程m3u失败: ${response.statusCode}';
      Global.logger.handle(err);
      throw Exception(err);
    }

    return response.data.toString();
  }

  /// 获取缓存m3u文件
  static Future<File> _getCacheFile() async {
    return File('${(await getTemporaryDirectory()).path}/iptv.m3u');
  }

  /// 获取缓存m3u
  static Future<String> _getCache() async {
    try {
      final cacheFile = await _getCacheFile();
      if (await cacheFile.exists()) {
        return await cacheFile.readAsString();
      }

      return '';
    } catch (err) {
      Global.logger.handle(err);
      return '';
    }
  }

  /// 解析m3u
  static List<IptvGroup> _parseFromM3u(String m3u) {
    var groupList = <IptvGroup>[];

    final lines = m3u.split('\n');

    var channel = 0;
    for (final (lineIdx, line) in lines.indexed) {
      if (!line.startsWith('#EXTINF:')) {
        continue;
      }

      final groupName = RegExp('group-title="(.*?)"').firstMatch(line)?.group(1) ?? '其他';
      final name = line.split(',')[1];

      if (IptvSettings.iptvType == IptvSettingIptvType.simple) {
        if (groupName != '总台高清' && groupName != '卫视高清') continue;
      }

      final group = groupList.firstWhere((it) => it.name == groupName, orElse: () {
        final group = IptvGroup(idx: groupList.length, name: groupName, list: []);
        groupList.add(group);
        return group;
      });

      final iptv = Iptv(
          idx: group.list.length,
          channel: ++channel,
          groupIdx: group.idx,
          name: name,
          url: lines[lineIdx + 1],
          tvgName: RegExp('tvg-name="(.*?)"').firstMatch(line)?.group(1) ?? '');

      group.list.add(iptv);
    }

    Global.logger.debug('[iptv] 解析m3u完成: ${groupList.length}个分组, $channel个频道');

    return groupList;
  }

  /// 刷新并获取iptv
  static Future<List<IptvGroup>> refreshAndGet() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (now - IptvSettings.iptvCacheTime < 24 * 60 * 60) {
      final cache = await _getCache();

      if (cache.isNotEmpty) {
        Global.logger.debug('[iptv] 使用缓存m3u');
        return _parseFromM3u(cache);
      }
    }

    final m3u = await _fetchM3u();

    final cacheFile = await _getCacheFile();
    await cacheFile.writeAsString(m3u);
    IptvSettings.iptvCacheTime = now;

    return _parseFromM3u(m3u);
  }
}
