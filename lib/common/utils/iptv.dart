import 'dart:io';

import 'package:my_tv/common/index.dart';
import 'package:path_provider/path_provider.dart';

/// IPTV工具类
class IPTVUtil {
  /// 解析m3u
  static List<IPTVGroup> parseFromM3u(String m3u) {
    var groupList = <IPTVGroup>[];

    final lines = m3u.split('\n');

    var channel = 0;
    for (final (lineIdx, line) in lines.indexed) {
      if (!line.startsWith('#EXTINF:')) {
        continue;
      }

      final groupName = RegExp('group-title="(.*?)"').firstMatch(line)?.group(1) ?? '其他';
      final name = line.split(',')[1];

      if (IPTVSettings.iptvType == IPTVSettingIPTVType.simple) {
        if (groupName != '总台高清' && groupName != '卫视高清') continue;
      }

      final group = groupList.firstWhere((it) => it.name == groupName, orElse: () {
        final group = IPTVGroup(idx: groupList.length, name: groupName, list: []);
        groupList.add(group);
        return group;
      });

      final iptv = IPTV(
        idx: group.list.length,
        channel: ++channel,
        groupIdx: group.idx,
        name: name,
        url: lines[lineIdx + 1],
      );

      group.list.add(iptv);
    }

    Global.logger.d('[IPTV] 解析m3u完成: ${groupList.length}个分组, $channel个频道');

    return groupList;
  }

  /// 获取远程m3u
  static Future<String> fetchM3u() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (now - IPTVSettings.iptvCacheTime < 24 * 60 * 60) {
      final cache = await getCacheM3u();

      if (cache.isNotEmpty) {
        Global.logger.d('[IPTV] 使用缓存m3u');
        return cache;
      }
    }

    Global.logger.d('[IPTV] 获取远程m3u: ${Constants.iptvM3u}');
    final response = await Global.dio.get(Constants.iptvM3u);
    if (response.statusCode != 200) {
      final err = '[IPTV] 获取远程m3u失败: ${response.statusCode}';
      Global.logger.e(err);
      throw Exception(err);
    }

    final m3u = response.data.toString();
    cacheM3u(m3u);

    return m3u;
  }

  /// 缓存m3u
  static Future<void> cacheM3u(String m3u) async {
    final cacheFile = File('${(await getTemporaryDirectory()).path}/IPTV.m3u');
    await cacheFile.writeAsString(m3u);
    IPTVSettings.iptvCacheTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// 获取缓存m3u
  static Future<String> getCacheM3u() async {
    final cacheFile = File('${(await getTemporaryDirectory()).path}/IPTV.m3u');
    if (await cacheFile.exists()) {
      return cacheFile.readAsString();
    }

    return '';
  }

  /// 清除m3u缓存
  static Future<void> clearCacheM3u() async {
    IPTVSettings.iptvCacheTime = 0;
    final cacheFile = File('${(await getTemporaryDirectory()).path}/IPTV.m3u');
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }
  }
}
