import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:my_tv/common/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

/// 电视节目单
class EpgUtil {
  /// 获取远程epg xml
  static Future<String> _fetchXml() async {
    Global.logger.debug('[EPG] 获取远程epg xml: ${Constants.iptvEpg}');

    final response = await Global.dio.get(Constants.iptvEpg);
    if (response.statusCode != 200) {
      final err = '[EPG] 获取远程epg失败: ${response.statusCode}';
      Global.logger.handle(err);
      throw Exception(err);
    }

    return response.data.toString();
  }

  /// 获取缓存epg xml文件
  static Future<File> _getCacheXmlFile() async {
    return File('${(await getTemporaryDirectory()).path}/epg.xml');
  }

  /// 获取缓存epg xml
  static Future<String?> _getCacheXml() async {
    try {
      final cacheFile = await _getCacheXmlFile();
      if (await cacheFile.exists()) {
        return await cacheFile.readAsString();
      }

      return null;
    } catch (err) {
      Global.logger.handle(err);
      return null;
    }
  }

  /// 刷新并获取epg xml
  static Future<String> _refreshAndGetXml() async {
    final now = DateTime.now();
    final cacheAt = DateTime.fromMillisecondsSinceEpoch(IptvSettings.epgXmlCacheTime * 1000);

    if (now.year == cacheAt.year && now.month == cacheAt.month && now.day == cacheAt.day) {
      final cache = await _getCacheXml();

      if (cache != null) {
        Global.logger.debug('[EPG] 使用缓存epg xml');
        return cache;
      }
    }

    final xml = await _fetchXml();

    final cacheFile = await _getCacheXmlFile();
    await cacheFile.writeAsString(xml);
    IptvSettings.epgXmlCacheTime = now.millisecondsSinceEpoch ~/ 1000;
    IptvSettings.epgCacheHash = 0;

    return xml;
  }

  /// 解析epg
  static List<Epg> _parseFromXml(String xml, List<String> filteredChannels) {
    int parseTime(String? time) {
      if (time == null || time.length < 14) return 0;

      return DateTime(
            int.parse(time.substring(0, 4)),
            int.parse(time.substring(4, 6)),
            int.parse(time.substring(6, 8)),
            int.parse(time.substring(8, 10)),
            int.parse(time.substring(10, 12)),
            int.parse(time.substring(12, 14)),
          ).millisecondsSinceEpoch ~/
          1000;
    }

    final doc = XmlDocument.parse(xml);
    final tvEl = doc.getElement('tv');

    final epgList = <Epg>[];
    Epg? epg;
    tvEl?.childElements.forEach((el) {
      final id = el.getAttribute('id');
      if (id != null) {
        if (epg != null) {
          epgList.add(epg!);
          epg = null;
        }

        if (filteredChannels.contains(id)) {
          epg = Epg(channel: id, programmes: []);
        }
      } else if (epg != null) {
        epg!.programmes.add(EpgProgramme(
          start: parseTime(el.getAttribute('start')),
          stop: parseTime(el.getAttribute('stop')),
          title: el.getElement('title')?.innerText ?? '',
        ));
      }
    });

    return epgList;
  }

  /// 获取缓存文件
  static Future<File> _getCacheFile() async {
    return File('${(await getTemporaryDirectory()).path}/epg.json');
  }

  /// 获取缓存epg
  static Future<List<Epg>?> _getCache() async {
    try {
      final cacheFile = await _getCacheFile();
      if (await cacheFile.exists()) {
        final str = await cacheFile.readAsString();
        List<dynamic> jsonList = jsonDecode(str);
        return jsonList.map((e) => Epg.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      Global.logger.handle(err);
      return null;
    }
  }

  /// 刷新并获取epg
  static Future<List<Epg>> refreshAndGet(List<String> filteredChannels) async {
    if (!IptvSettings.epgEnable) return [];

    final xml = await _refreshAndGetXml();

    final hashcode = filteredChannels.map((str) => str.hashCode).reduce((value, element) => value ^ element);

    if (IptvSettings.epgCacheHash == hashcode) {
      final cache = await _getCache();

      if (cache != null) {
        Global.logger.debug('[EPG] 使用缓存epg');
        return cache;
      }
    }

    Global.logger.debug('[EPG] 开始解析epg');
    final startAt = DateTime.now().millisecondsSinceEpoch;
    final epgList = await compute((_) => _parseFromXml(xml, filteredChannels), 0);
    Global.logger.debug('[EPG] 解析epg完成，共${epgList.length}个频道，耗时：${DateTime.now().millisecondsSinceEpoch - startAt}ms');

    final cacheFile = await _getCacheFile();
    await cacheFile.writeAsString(jsonEncode(epgList.map((e) => e.toJson()).toList()));
    IptvSettings.epgCacheHash = hashcode;

    return epgList;
  }
}
