import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';
import 'package:my_tv/pages/index.dart';
import 'package:my_tv/pages/panel/widgets/iptv_info.dart';
import 'package:video_player/video_player.dart';

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
    playerStore.controller.pause().then((_) => playerStore.controller.dispose());
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

    reaction((_) => iptvStore.iptvList, (list) async {
      iptvStore.refreshEpgList();
    });

    await iptvStore.refreshIptvList();
    iptvStore.currentIptv = iptvStore.iptvList[IptvSettings.initialIptvIdx];

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

  Widget _buildIptvInfo() {
    return Observer(
      builder: (_) => iptvStore.iptvInfoVisible
          ? Stack(
              children: [
                Positioned(
                  top: 20.h,
                  right: 20.w,
                  child: Text(
                    iptvStore.currentIptv.channel.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 90.sp,
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(40).r,
                    child: PanelIptvInfo(),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  /// 键盘事件监听
  Widget _buildKeyboardListener() {
    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      child: Container(),
      onKeyEvent: (event) {
        if (event.runtimeType == KeyUpEvent) {
          // 频道切换
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (IptvSettings.channelChangeFlip) {
              iptvStore.currentIptv = iptvStore.getNextIptv();
            } else {
              iptvStore.currentIptv = iptvStore.getPrevIptv();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (IptvSettings.channelChangeFlip) {
              iptvStore.currentIptv = iptvStore.getPrevIptv();
            } else {
              iptvStore.currentIptv = iptvStore.getNextIptv();
            }
          }
          // else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          //   iptvStore.currentIptv = iptvStore.getPrevGroupIptv();
          // } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          //   iptvStore.currentIptv = iptvStore.getNextGroupIptv();
          // }

          // 打开面板
          else if (event.logicalKey == LogicalKeyboardKey.select) {
            _openPanel();
          }

          // 打开设置
          else if ([
            LogicalKeyboardKey.settings,
            LogicalKeyboardKey.contextMenu,
            LogicalKeyboardKey.help,
          ].any((it) => it == event.logicalKey)) {
            _openSettings();
          }

          // 数字选台
          else if (event.logicalKey == LogicalKeyboardKey.digit0) {
            iptvStore.inputChannelNo('0');
          } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
            iptvStore.inputChannelNo('1');
          } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
            iptvStore.inputChannelNo('2');
          } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
            iptvStore.inputChannelNo('3');
          } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
            iptvStore.inputChannelNo('4');
          } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
            iptvStore.inputChannelNo('5');
          } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
            iptvStore.inputChannelNo('6');
          } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
            iptvStore.inputChannelNo('7');
          } else if (event.logicalKey == LogicalKeyboardKey.digit8) {
            iptvStore.inputChannelNo('8');
          } else if (event.logicalKey == LogicalKeyboardKey.digit9) {
            iptvStore.inputChannelNo('9');
          }
        }

        if (event.runtimeType == KeyRepeatEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select) {
            _openSettings();
          }
        }
      },
    );
  }

  /// 手势事件监听
  Widget _buildGestureListener({required Widget child}) {
    return DirectionGestureDetector(
      onDragUp: () => iptvStore.currentIptv = iptvStore.getNextIptv(),
      onDragDown: () => iptvStore.currentIptv = iptvStore.getPrevIptv(),
      // onDragLeft: () => iptvStore.currentIptv = iptvStore.getPrevGroupIptv(),
      // onDragRight: () => iptvStore.currentIptv = iptvStore.getNextGroupIptv(),
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          _openPanel();
        },
        onDoubleTap: () {
          _openSettings();
        },
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
        builder: (_) => Text(
          iptvStore.channelNo,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 90.sp,
            height: 1,
          ),
        ),
      ),
    );
  }

  Future<void> _openPanel() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 透明渐变
          return FadeTransition(
            opacity: animation.drive(
              Tween<double>(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          );
        },
        pageBuilder: (context, _, __) {
          return const PanelPage();
        },
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 透明渐变
          return FadeTransition(
            opacity: animation.drive(
              Tween<double>(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          );
        },
        pageBuilder: (context, _, __) {
          return const SettingsPage();
        },
      ),
    );
  }
}
