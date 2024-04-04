import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';

class SettingGroup {
  final String name;
  final List<SettingItem> items;

  SettingGroup({required this.name, required this.items});
}

class SettingItem {
  final String title;
  final String Function() value;
  final String Function() description;
  final void Function() onTap;
  int groupIdx;

  SettingItem({
    required this.title,
    required this.value,
    required this.description,
    required this.onTap,
    this.groupIdx = 0,
  });
}

class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key});

  @override
  State<SettingsMain> createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  final iptvStore = GetIt.I<IptvStore>();
  final updateStore = GetIt.I<UpdateStore>();

  final _focusNode = FocusNode();
  late final List<SettingItem> _settingItemList;
  var _selectedIdx = 0;
  final _scrollController = ScrollController();

  void refreshSettingGroupList() {
    final groupList = [
      SettingGroup(name: '应用', items: [
        SettingItem(
          title: '应用更新',
          value: () => updateStore.needUpdate ? '新版本' : '无更新',
          description: () => '最新版本：${updateStore.latestRelease.tagName}',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(updateStore.latestRelease.tagName),
                content: SingleChildScrollView(
                  child: Text(updateStore.latestRelease.description),
                ),
              ),
            );
          },
        ),
        SettingItem(
          title: '开机自启',
          value: () => AppSettings.bootLaunch ? '启用' : '禁用',
          description: () => '下次重启生效',
          onTap: () {
            AppSettings.bootLaunch = !AppSettings.bootLaunch;
          },
        ),
      ]),
      SettingGroup(name: '控制', items: [
        SettingItem(
          title: '换台反转',
          value: () => IptvSettings.channelChangeFlip ? '反转' : '正常',
          description: () => IptvSettings.channelChangeFlip ? '方向键上：下一个频道，方向键下：上一个频道' : '方向键上：上一个频道，方向键下：下一个频道',
          onTap: () {
            IptvSettings.channelChangeFlip = !IptvSettings.channelChangeFlip;
          },
        ),
      ]),
      SettingGroup(name: '直播源', items: [
        SettingItem(
          title: '直播源精简',
          value: () => IptvSettings.iptvSourceSimplify ? '启用' : '禁用',
          description: () => IptvSettings.iptvSourceSimplify ? '显示精简直播源(仅央视、地方卫视)' : '显示完整直播源',
          onTap: () {
            IptvSettings.iptvSourceSimplify = !IptvSettings.iptvSourceSimplify;
            IptvSettings.epgCacheHash = 0;
            iptvStore.refreshIptvList();
          },
        ),
        SettingItem(
          title: '自定义直播源',
          value: () => IptvSettings.customIptvSource.isNotEmpty ? '已启用' : '未启用',
          description: () => '访问以下网址进行配置：${HttpServerUtil.serverUrl}',
          onTap: () {
            if (IptvSettings.customIptvSource.isNotEmpty) {
              iptvStore.refreshIptvList();
            }
          },
        ),
        SettingItem(
          title: '直播源缓存',
          value: () => '24小时',
          description: () => IptvSettings.iptvSourceCacheTime > 0 ? "已缓存(点击清除缓存)" : "未缓存",
          onTap: () {
            if (IptvSettings.iptvSourceCacheTime > 0) {
              IptvSettings.iptvSourceCacheTime = 0;
              iptvStore.refreshIptvList();
            }
          },
        ),
      ]),
      SettingGroup(name: '节目单', items: [
        SettingItem(
          title: '节目单',
          value: () => IptvSettings.epgEnable ? '启用' : '禁用',
          description: () => '首次加载时可能会有跳帧风险',
          onTap: () {
            IptvSettings.epgEnable = !IptvSettings.epgEnable;
            iptvStore.refreshEpgList();
          },
        ),
        SettingItem(
          title: '节目单缓存',
          value: () => '当天',
          description: () => IptvSettings.epgXmlCacheTime > 0 ? "已缓存(点击清除缓存)" : "未缓存",
          onTap: () {
            if (IptvSettings.epgXmlCacheTime > 0) {
              IptvSettings.epgXmlCacheTime = 0;
              IptvSettings.epgCacheHash = 0;
              iptvStore.refreshEpgList();
            }
          },
        ),
      ]),
    ];

    // 设置组索引
    for (var i = 0; i < groupList.length; i++) {
      for (var j = 0; j < groupList[i].items.length; j++) {
        groupList[i].items[j].groupIdx = i;
      }
    }

    _settingItemList = groupList.expand((element) => element.items).toList();
  }

  @override
  void initState() {
    super.initState();
    refreshSettingGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingGroupList(),
        _buildKeyboardListener(),
      ],
    );
  }

  void _changeSelected(int idx) {
    setState(() {
      _selectedIdx = idx.clamp(0, _settingItemList.length - 1);
    });

    _scrollController.animateTo(
      ((_selectedIdx - 1) * 400.w).clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  Widget _buildSettingGroupList() {
    return SizedBox(
      height: 190.w,
      child: ListView.separated(
        itemBuilder: (context, index) => _buildSettingItem(_settingItemList[index]),
        separatorBuilder: ((context, idx) => SizedBox(width: 20.w)),
        itemCount: _settingItemList.length,
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
      ),
    );
  }

  Widget _buildSettingItem(SettingItem item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _selectedIdx = _settingItemList.indexOf(item);
        item.onTap();
      }),
      child: Container(
        width: 400.w,
        padding: const EdgeInsets.all(30).r,
        decoration: BoxDecoration(
          color: _selectedIdx == _settingItemList.indexOf(item)
              ? Theme.of(context).colorScheme.onBackground
              : Theme.of(context).colorScheme.background.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20).r,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: _selectedIdx == _settingItemList.indexOf(item)
                        ? Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.onBackground,
                    fontSize: 30.sp,
                  ),
                ),
                Text(
                  item.value(),
                  style: TextStyle(
                    color: _selectedIdx == _settingItemList.indexOf(item)
                        ? Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.onBackground,
                    fontSize: 30.sp,
                  ),
                ),
              ],
            ),
            Text(
              item.description(),
              style: TextStyle(
                color: _selectedIdx == _settingItemList.indexOf(item)
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onBackground,
                fontSize: 24.sp,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardListener() {
    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      child: Container(),
      onKeyEvent: (event) {
        if (event.runtimeType == KeyUpEvent) {
          // 上一分组
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            final preGroupIdx = _settingItemList.elementAt(_selectedIdx).groupIdx - 1;
            final item = _settingItemList.firstWhereOrNull((element) => element.groupIdx == preGroupIdx);
            if (item != null) {
              _changeSelected(_settingItemList.indexOf(item));
            }
          }
          // 下一分组
          else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            final nextGroupIdx = _settingItemList.elementAt(_selectedIdx).groupIdx + 1;
            final item = _settingItemList.firstWhereOrNull((element) => element.groupIdx == nextGroupIdx);
            if (item != null) {
              _changeSelected(_settingItemList.indexOf(item));
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _changeSelected(_selectedIdx - 1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _changeSelected(_selectedIdx + 1);
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            setState(() {
              if (_selectedIdx >= 0) {
                _settingItemList.elementAtOrNull(_selectedIdx)?.onTap();
              }
            });
          }
          // else {
          //   if (_selectedIdx == _settingItemList.length - 1) {
          //     ScaffoldMessenger.of(context).clearSnackBars();
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Text(
          //             '按键: keyLabel(${event.logicalKey.keyLabel}), keyId(${event.logicalKey.keyId}), usbHidUsage(${event.physicalKey.usbHidUsage})'),
          //       ),
          //     );
          //   }
          // }
        }
      },
    );
  }
}
