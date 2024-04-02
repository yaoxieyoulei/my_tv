import 'dart:async';

import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';

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
  @observable
  List<Epg>? epgList;

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
    iptvGroupList = await IPTVUtil.refreshAndGet();
    iptvList = iptvGroupList.expand((e) => e.list).toList();
  }

  /// 手动输入频道号
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

  @computed
  ({String current, String next}) get currentIPTVProgrammes {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final epg = epgList?.firstWhereOrNull((element) => element.channel == currentIPTV.tvgName);

    final currentProgramme = epg?.programmes.firstWhereOrNull((element) => element.start <= now && element.stop >= now);
    final nextProgramme = epg?.programmes.firstWhereOrNull((element) => element.start > now);

    return (current: currentProgramme?.title ?? '无节目', next: nextProgramme?.title ?? '无节目');
  }
}
