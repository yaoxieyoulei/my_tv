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
  final iptvStore = GetIt.I<IPTVStore>();

  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  late final List<({Widget Function(int) Function() widget, void Function() onTap})> _defList;

  var _selectedIdx = 0;

  @override
  void initState() {
    super.initState();
    refreshDefList();
  }

  void refreshDefList() {
    _defList = [
      (
        widget: () => _buildSettingsItem(
              title: '开机自启',
              value: IPTVSettings.bootLaunch ? '启用' : '禁用',
              description: '下次重启生效',
            ),
        onTap: () {
          IPTVSettings.bootLaunch = !IPTVSettings.bootLaunch;
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '直播源类型',
              value: IPTVSettings.iptvType.name,
              description: IPTVSettings.iptvType == IPTVSettingIPTVType.full ? '显示完整直播源' : '显示精简直播源(仅央视、地方卫视)',
            ),
        onTap: () {
          IPTVSettings.iptvType =
              IPTVSettingIPTVType.values[(IPTVSettings.iptvType.index + 1) % IPTVSettingIPTVType.values.length];
          IPTVSettings.epgCacheHash = 0;
          iptvStore.refreshIPTVList();
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '换台反转',
              value: IPTVSettings.channelChangeFlip ? '反转' : '正常',
              description: IPTVSettings.channelChangeFlip ? '方向键上：下一个频道，方向键下：上一个频道' : '方向键上：上一个频道，方向键下：下一个频道',
            ),
        onTap: () {
          IPTVSettings.channelChangeFlip = !IPTVSettings.channelChangeFlip;
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '平滑换台',
              value: IPTVSettings.smoothChangeChannel ? '启用' : '禁用',
              description: '切换频道时无黑屏，启用后部分设备可能无法换台',
            ),
        onTap: () {
          IPTVSettings.smoothChangeChannel = !IPTVSettings.smoothChangeChannel;
        },
      ),
      (
        widget: () => _buildSettingsItem(
              title: '直播源缓存',
              value: '24小时',
              description: IPTVSettings.iptvCacheTime > 0 ? "已缓存(点击清除缓存)" : "未缓存",
            ),
        onTap: () {
          if (IPTVSettings.iptvCacheTime > 0) {
            IPTVSettings.iptvCacheTime = 0;
            iptvStore.refreshIPTVList();
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
        (_selectedIdx - 1) * 520.h,
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
            _defList[_selectedIdx].onTap();
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
