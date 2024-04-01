/// 直播源
class IPTV {
  /// 序号
  late int idx;

  /// 频道号
  late int channel;

  /// 所属分组
  late int groupIdx;

  /// 名称
  late String name;

  /// 播放地址
  late String url;

  IPTV({
    required this.idx,
    required this.channel,
    required this.groupIdx,
    required this.name,
    required this.url,
  });

  @override
  String toString() {
    return 'IPTV{idx: $idx, channel: $channel, groupIdx: $groupIdx, name: $name, url: $url}';
  }
}

/// 直播源分组
class IPTVGroup {
  /// 序号
  late int idx;

  /// 名称
  late String name;

  /// 直播源列表
  late List<IPTV> list;

  IPTVGroup({required this.idx, required this.name, required this.list});

  @override
  String toString() {
    return 'IPTVGroup{idx: $idx, name: $name, list: ${list.length}}';
  }
}
