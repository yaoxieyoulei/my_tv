import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_tv/common/index.dart';

/// IPTV工具类
class IPTVUtil {
  /// 解析m3u
  static Future<List<IPTVGroup>> parseFromM3u(String m3u) async {
    var groupList = <IPTVGroup>[];

    final lines = m3u.split('\n');

    var channel = 0;
    for (final (lineIdx, line) in lines.indexed) {
      if (!line.startsWith('#EXTINF:')) {
        continue;
      }

      final name = line.split(',')[1];

      final groupName = RegExp('group-title="(.*?)"').firstMatch(line)?.group(1) ?? '其他';
      final group = groupList.firstWhere((it) => it.name == groupName, orElse: () {
        final group = IPTVGroup(idx: groupList.length, name: groupName, list: []);
        groupList.add(group);
        return group;
      });

      final iptv = IPTV(
        idx: group.list.length,
        channel: ++channel,
        group: group,
        name: name,
        url: lines[lineIdx + 1],
        logo: RegExp('tvg-logo="(.*?)"').firstMatch(line)?.group(1),
      );

      group.list.add(iptv);
    }

    Global.logger.d('[IPTV] 解析m3u完成: ${groupList.length}个分组, $channel个频道');

    return groupList;
  }

  /// 获取远程m3u
  /// TODO 链接缓存
  static Future<String> fetchM3u() async {
    Global.logger.d('[IPTV] 获取远程m3u: ${Constants.iptvM3u}');
    final response = await Global.dio.get(Constants.iptvM3u);
    if (response.statusCode != 200) {
      final err = '[IPTV] 获取远程m3u失败: ${response.statusCode}';
      Global.logger.e(err);
      Fluttertoast.showToast(msg: err);
      throw Exception(err);
    }
    return response.data.toString();
  }
}
