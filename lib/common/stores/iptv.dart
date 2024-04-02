import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';

part 'iptv.g.dart';

class IPTVStore = IPTVStoreBase with _$IPTVStore;

abstract class IPTVStoreBase with Store {
  /// 直播源分组列表
  @observable
  List<IPTVGroup> iptvGroupList = [];

  /// 直播源列表
  @observable
  List<IPTV> iptvList = [];

  /// 当前直播源
  @observable
  IPTV currentIPTV = IPTV.empty;

  /// 显示iptv信息
  @observable
  bool iptvInfoVisible = false;

  /// 选台频道号
  @observable
  String channelNo = '';

  /// 确认选台定时器
  Timer? confirmChannelTimer;

  /// 节目单
  XmlDocument? epg;

  /// 获取上一个直播源
  IPTV getPrevIPTV({IPTV? iptv}) {
    final prevIdx = iptvList.indexOf(iptv ?? currentIPTV) - 1;
    return prevIdx < 0 ? iptvList.last : iptvList.elementAt(prevIdx);
  }

  /// 获取下一个直播源
  IPTV getNextIPTV({IPTV? iptv}) {
    final nextIdx = iptvList.indexOf(iptv ?? currentIPTV) + 1;
    return nextIdx >= iptvList.length ? iptvList.first : iptvList.elementAt(nextIdx);
  }

  /// 获取上一个分组直播源
  IPTV getPrevGroupIPTV({IPTV? iptv}) {
    final prevIdx = (iptv?.groupIdx ?? currentIPTV.groupIdx) - 1;
    return prevIdx < 0 ? iptvGroupList.last.list.first : iptvGroupList.elementAt(prevIdx).list.first;
  }

  /// 获取下一个分组直播源
  IPTV getNextGroupIPTV({IPTV? iptv}) {
    final nextIdx = (iptv?.groupIdx ?? currentIPTV.groupIdx) + 1;
    return nextIdx >= iptvGroupList.length
        ? iptvGroupList.first.list.first
        : iptvGroupList.elementAt(nextIdx).list.first;
  }

  /// 刷新直播源列表
  @action
  Future<void> refreshIPTVList() async {
    iptvGroupList = IPTVUtil.parseFromM3u(await IPTVUtil.fetchM3u());
    iptvList = iptvGroupList.expand((e) => e.list).toList();
  }

  void inputChannelNo(String no) {
    confirmChannelTimer?.cancel();

    channelNo += no;
    confirmChannelTimer = Timer(Duration(seconds: 4 - channelNo.length), () {
      final channel = int.tryParse(channelNo) ?? 0;
      final iptv = iptvList.firstWhere((e) => e.channel == channel, orElse: () => currentIPTV);
      currentIPTV = iptv;
      channelNo = '';
    });
  }

  /// 刷新epg
  Future<void> refreshEpgXML() async {
    epg = XmlDocument.parse(await IPTVUtil.fetchEpg());
  }

  @computed
  ({String current, String next}) get currentIPTVProgrammes {
    final programmeList = epg
        ?.getElement('tv')
        ?.findAllElements('programme')
        .where((element) => element.getAttribute('channel') == currentIPTV.tvgName)
        .toList();

    final currentProgramme = programmeList?.firstWhereOrNull((element) {
      final start = element.getAttribute('start')!;
      final startTime = DateTime(
        int.parse(start.substring(0, 4)),
        int.parse(start.substring(4, 6)),
        int.parse(start.substring(6, 8)),
        int.parse(start.substring(8, 10)),
        int.parse(start.substring(10, 12)),
        int.parse(start.substring(12, 14)),
      );

      final stop = element.getAttribute('stop')!;
      final stopTime = DateTime(
        int.parse(stop.substring(0, 4)),
        int.parse(stop.substring(4, 6)),
        int.parse(stop.substring(6, 8)),
        int.parse(stop.substring(8, 10)),
        int.parse(stop.substring(10, 12)),
        int.parse(stop.substring(12, 14)),
      );

      return startTime.isBefore(DateTime.now()) && stopTime.isAfter(DateTime.now());
    });
    final nextProgramme = currentProgramme?.nextElementSibling;

    return (
      current: currentProgramme?.getElement('title')?.innerText ?? '无节目',
      next: nextProgramme?.getElement('title')?.innerText ?? '无节目'
    );
  }
}
