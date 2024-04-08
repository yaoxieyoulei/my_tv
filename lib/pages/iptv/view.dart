import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';
import 'package:my_tv/pages/index.dart';
import 'package:my_tv/pages/panel/widgets/iptv_ch.dart';
import 'package:my_tv/pages/panel/widgets/iptv_info.dart';
import 'package:video_player/video_player.dart';
import 'package:collection/collection.dart';

class IptvPage extends StatefulWidget {
  const IptvPage({super.key});

  @override
  State<IptvPage> createState() => _IptvPageState();
}

class _IptvPageState extends State<IptvPage> {
  final playerStore = GetIt.I<PlayerStore>();
  final iptvStore = GetIt.I<IptvStore>();
  final updateStore = GetIt.I<UpdateStore>();

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initData() async {
    reaction((_) => iptvStore.currentIptv, (iptv) async {
      IptvSettings.initialIptvIdx = iptvStore.iptvList.indexOf(iptv);

      iptvStore.iptvInfoVisible = true;
      await playerStore.playIptv(iptvStore.currentIptv);
      Timer(const Duration(seconds: 1), () {
        if (iptv == iptvStore.currentIptv) {
          iptvStore.iptvInfoVisible = false;
        }
      });
    });

    reaction((_) => iptvStore.iptvList, (list) {
      iptvStore.refreshEpgList();
    });

    await iptvStore.refreshIptvList();
    iptvStore.currentIptv = iptvStore.iptvList.elementAtOrNull(IptvSettings.initialIptvIdx) ?? iptvStore.iptvList.first;

    updateStore.refreshLatestRelease();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildGestureListener(
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              _buildPlayer(),
              _buildIptvInfo(),
              _buildKeyboardListener(),
              _buildChannelSelect(),
            ],
          ),
        ),
      ),
    );
  }

  /// 播放器主界面
  Center _buildPlayer() {
    return Center(
      child: Observer(
        builder: (_) => AspectRatio(
          aspectRatio: playerStore.aspectRatio ?? 16 / 9,
          child: VideoPlayer(playerStore.controller),
        ),
      ),
    );
  }

  /// 当前直播源信息
  Widget _buildIptvInfo() {
    return Observer(
      builder: (_) => iptvStore.iptvInfoVisible
          ? Stack(
              children: [
                // 频道号
                Positioned(
                  top: 20.h,
                  right: 20.w,
                  child: PanelIptvChannel(iptvStore.currentIptv.channel.toString().padLeft(2, '0')),
                ),
                // 频道信息
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20).r,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20).r,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20).r,
                          ),
                          child: PanelIptvInfo(epgShowFull: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  /// 键盘事件监听
  Widget _buildKeyboardListener() {
    return EasyKeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKeyTap: {
        // 频道切换
        LogicalKeyboardKey.arrowUp: () {
          if (IptvSettings.channelChangeFlip) {
            iptvStore.currentIptv = iptvStore.getNextIptv();
          } else {
            iptvStore.currentIptv = iptvStore.getPrevIptv();
          }
        },
        LogicalKeyboardKey.arrowDown: () {
          if (IptvSettings.channelChangeFlip) {
            iptvStore.currentIptv = iptvStore.getPrevIptv();
          } else {
            iptvStore.currentIptv = iptvStore.getNextIptv();
          }
        },
        // LogicalKeyboardKey.arrowLeft: ()=> iptvStore.currentIptv = iptvStore.getPrevGroupIptv(),
        // LogicalKeyboardKey.arrowRight: ()=> iptvStore.currentIptv = iptvStore.getNextGroupIptv(),

        // 打开面板
        LogicalKeyboardKey.select: () => _openPanel(),

        // 打开设置
        LogicalKeyboardKey.settings: () => _openSettings(),
        LogicalKeyboardKey.contextMenu: () => _openSettings(),
        LogicalKeyboardKey.help: () => _openSettings(),

        // 数字选台
        LogicalKeyboardKey.digit0: () => iptvStore.inputChannelNo('0'),
        LogicalKeyboardKey.digit1: () => iptvStore.inputChannelNo('1'),
        LogicalKeyboardKey.digit2: () => iptvStore.inputChannelNo('2'),
        LogicalKeyboardKey.digit3: () => iptvStore.inputChannelNo('3'),
        LogicalKeyboardKey.digit4: () => iptvStore.inputChannelNo('4'),
        LogicalKeyboardKey.digit5: () => iptvStore.inputChannelNo('5'),
        LogicalKeyboardKey.digit6: () => iptvStore.inputChannelNo('6'),
        LogicalKeyboardKey.digit7: () => iptvStore.inputChannelNo('7'),
        LogicalKeyboardKey.digit8: () => iptvStore.inputChannelNo('8'),
        LogicalKeyboardKey.digit9: () => iptvStore.inputChannelNo('9'),
      },
      onKeyLongTap: {
        LogicalKeyboardKey.select: () => _openSettings(),
      },
      child: Container(),
    );
  }

  /// 手势事件监听
  Widget _buildGestureListener({required Widget child}) {
    return SwipeGestureDetector(
      onSwipeUp: () => iptvStore.currentIptv = iptvStore.getNextIptv(),
      onSwipeDown: () => iptvStore.currentIptv = iptvStore.getPrevIptv(),
      // onDragLeft: () => iptvStore.currentIptv = iptvStore.getPrevGroupIptv(),
      // onDragRight: () => iptvStore.currentIptv = iptvStore.getNextGroupIptv(),
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          _openPanel();
        },
        onDoubleTap: () => _openSettings(),
        child: child,
      ),
    );
  }

  /// 数字选台
  Widget _buildChannelSelect() {
    return Positioned(
      top: 20.h,
      right: 20.w,
      child: Observer(
        builder: (_) => PanelIptvChannel(iptvStore.channelNo),
      ),
    );
  }

  void _openPanel() {
    NavigatorUtil.push(context, const PanelPage());
  }

  void _openSettings() {
    NavigatorUtil.push(context, const SettingsPage());
  }
}
