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

class IPTVPage extends StatefulWidget {
  const IPTVPage({super.key});

  @override
  State<IPTVPage> createState() => _IPTVPageState();
}

class _IPTVPageState extends State<IPTVPage> {
  final playerStore = GetIt.I<PlayerStore>();
  final iptvStore = GetIt.I<IPTVStore>();

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
    reaction((_) => iptvStore.currentIPTV, (iptv) async {
      IPTVSettings.initialIPTVIdx = iptvStore.iptvList.indexOf(iptv);

      iptvStore.iptvInfoVisible = true;

      await playerStore.playIPTV(iptvStore.currentIPTV);

      Timer(const Duration(seconds: 1), () {
        if (iptv == iptvStore.currentIPTV) {
          iptvStore.iptvInfoVisible = false;
        }
      });
    });

    // TODO 卡顿
    // iptvStore.refreshEpgXML();
    await iptvStore.refreshIPTVList();
    iptvStore.currentIPTV = iptvStore.iptvList[IPTVSettings.initialIPTVIdx];
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
              _buildIPTVInfo(),
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

  Widget _buildIPTVInfo() {
    return Observer(
      builder: (_) => iptvStore.iptvInfoVisible
          ? Stack(
              children: [
                Positioned(
                  top: 20.h,
                  right: 20.w,
                  child: Text(
                    iptvStore.currentIPTV.channel.toString().padLeft(2, '0'),
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
                    child: PanelIPTVInfo(),
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
        if (event.runtimeType != KeyUpEvent) return;

        // 频道切换
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (IPTVSettings.channelChangeFlip) {
            iptvStore.currentIPTV = iptvStore.getNextIPTV();
          } else {
            iptvStore.currentIPTV = iptvStore.getPrevIPTV();
          }
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (IPTVSettings.channelChangeFlip) {
            iptvStore.currentIPTV = iptvStore.getPrevIPTV();
          } else {
            iptvStore.currentIPTV = iptvStore.getNextIPTV();
          }
        }
        // else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        //   iptvStore.currentIPTV = iptvStore.getPrevGroupIPTV();
        // } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        //   iptvStore.currentIPTV = iptvStore.getNextGroupIPTV();
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
      },
    );
  }

  /// 手势事件监听
  Widget _buildGestureListener({required Widget child}) {
    return DirectionGestureDetector(
      onDragUp: () => iptvStore.currentIPTV = iptvStore.getNextIPTV(),
      onDragDown: () => iptvStore.currentIPTV = iptvStore.getPrevIPTV(),
      // onDragLeft: () => iptvStore.currentIPTV = iptvStore.getPrevGroupIPTV(),
      // onDragRight: () => iptvStore.currentIPTV = iptvStore.getNextGroupIPTV(),
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
