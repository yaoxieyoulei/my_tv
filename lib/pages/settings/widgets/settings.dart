import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';

class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key});

  @override
  State<SettingsMain> createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  final iptvStore = GetIt.I<IptvStore>();
  final updateStore = GetIt.I<UpdateStore>();

  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  late final List<({Widget Function(int) Function() widget, void Function() onTap})> _defList;

  var _selectedIdx = -1;

  @override
  void initState() {
    super.initState();
    refreshDefList();
  }

  void refreshDefList() {
    _defList = [
      (
        widget: () => _buildSettingsItem(
              title: '应用更新',
              value: updateStore.needUpdate ? '新版本' : '无更新',
              description: '最新版本：${updateStore.latestRelease.tagName}',
            ),
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
      (
        widget: () => _buildSettingsItem(
              title: '开机自启',
              value: IptvSettings.bootLaunch ? '启用' : '禁用',
              description: '下次重启生效',
            ),
        onTap: () {
          IptvSettings.bootLaunch = !IptvSettings.bootLaunch;
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '直播源类型',
              value: IptvSettings.iptvType.name,
              description: IptvSettings.iptvType == IptvSettingIptvType.full ? '显示完整直播源' : '显示精简直播源(仅央视、地方卫视)',
            ),
        onTap: () {
          IptvSettings.iptvType =
              IptvSettingIptvType.values[(IptvSettings.iptvType.index + 1) % IptvSettingIptvType.values.length];
          IptvSettings.epgCacheHash = 0;
          iptvStore.refreshIptvList();
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '自定义直播源',
              value: IptvSettings.customIptvM3u.isNotEmpty ? '已启用' : '未启用',
              description: '访问以下网址进行配置：http:://<设备IP>:${Constants.httpServerPort}',
            ),
        onTap: () {
          iptvStore.refreshIptvList();
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '节目单',
              value: IptvSettings.epgEnable ? '启用' : '禁用',
              description: '首次加载时可能会有跳帧风险',
            ),
        onTap: () {
          IptvSettings.epgEnable = !IptvSettings.epgEnable;
          iptvStore.refreshEpgList();
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '换台反转',
              value: IptvSettings.channelChangeFlip ? '反转' : '正常',
              description: IptvSettings.channelChangeFlip ? '方向键上：下一个频道，方向键下：上一个频道' : '方向键上：上一个频道，方向键下：下一个频道',
            ),
        onTap: () {
          IptvSettings.channelChangeFlip = !IptvSettings.channelChangeFlip;
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '平滑换台',
              value: IptvSettings.smoothChangeChannel ? '启用' : '禁用',
              description: '切换频道时无黑屏，启用后部分设备可能无法换台',
            ),
        onTap: () {
          IptvSettings.smoothChangeChannel = !IptvSettings.smoothChangeChannel;
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '直播源缓存',
              value: '24小时',
              description: IptvSettings.iptvCacheTime > 0 ? "已缓存(点击清除缓存)" : "未缓存",
            ),
        onTap: () {
          if (IptvSettings.iptvCacheTime > 0) {
            IptvSettings.iptvCacheTime = 0;
            iptvStore.refreshIptvList();
          }
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '节目单缓存',
              value: '当天',
              description: IptvSettings.epgXmlCacheTime > 0 ? "已缓存(点击清除缓存)" : "未缓存",
            ),
        onTap: () {
          if (IptvSettings.epgXmlCacheTime > 0) {
            IptvSettings.epgXmlCacheTime = 0;
            IptvSettings.epgCacheHash = 0;
            iptvStore.refreshEpgList();
          }
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '按键测试',
              value: '',
              description: '选中该项后，按任意键测试',
            ),
        onTap: () {},
      ),
    ];
  }

  void _changeSelected(int idx) {
    setState(() {
      _selectedIdx = (idx + _defList.length) % _defList.length;
    });

    _scrollController.animateTo(
      clampDouble(
        (_selectedIdx - 1) * 520.w,
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设置',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 170.h,
          child: ListView.separated(
            controller: _scrollController,
            itemBuilder: (context, index) => _defList[index].widget()(index),
            separatorBuilder: (context, idx) => SizedBox(width: 20.w),
            itemCount: _defList.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
        _buildKeyboardListener(),
      ],
    );
  }

  Widget Function(int) _buildSettingsItem({
    required String title,
    required String value,
    required String description,
  }) {
    return (int index) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() {
            _selectedIdx = index;
            _defList[index].onTap();
          }),
          child: Container(
            width: 500.w,
            padding: const EdgeInsets.all(30).r,
            decoration: BoxDecoration(
              color: _selectedIdx == index
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
                      title,
                      style: TextStyle(
                        color: _selectedIdx == index
                            ? Theme.of(context).colorScheme.background
                            : Theme.of(context).colorScheme.onBackground,
                        fontSize: 36.sp,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: _selectedIdx == index
                            ? Theme.of(context).colorScheme.background
                            : Theme.of(context).colorScheme.onBackground,
                        fontSize: 36.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: _selectedIdx == index
                        ? Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.onBackground,
                    fontSize: 30.sp,
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
        if (event.runtimeType != KeyUpEvent) return;

        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _changeSelected(_selectedIdx - 1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _changeSelected(_selectedIdx + 1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _changeSelected(_selectedIdx - 1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _changeSelected(_selectedIdx + 1);
        } else if (event.logicalKey == LogicalKeyboardKey.select) {
          setState(() {
            if (_selectedIdx >= 0) {
              _defList.elementAtOrNull(_selectedIdx)?.onTap();
            }
          });
        } else {
          if (_selectedIdx == _defList.length - 1) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '按键: keyLabel(${event.logicalKey.keyLabel}), keyId(${event.logicalKey.keyId}), usbHidUsage(${event.physicalKey.usbHidUsage})'),
              ),
            );
          }
        }
      },
    );
  }
}
