import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';

part 'player.g.dart';

class PlayerStore = PlayerStoreBase with _$PlayerStore;

/// 播放状态
enum PlayerState {
  /// 等待播放
  waiting,

  /// 播放中
  playing,

  /// 播放失败
  failed,
}

final _logger = LoggerUtil.create(['播放器']);

abstract class PlayerStoreBase with Store {
  final controller = Media3PlayerController();

  /// 宽高比
  @observable
  double? aspectRatio;

  /// 分辨率
  @observable
  Size resolution = Size.zero;

  /// 播放状态
  @observable
  PlayerState state = PlayerState.waiting;

  @action
  Future<void> init() async {
    await controller.create();
  }

  /// 播放直播源
  @action
  Future<void> playIptv(Iptv iptv) async {
    try {
      _logger.debug('播放直播源: $iptv');
      state = PlayerState.waiting;

      final contentType = Uri.parse(iptv.url).path.endsWith('.php') ? Media3PlayerVideoContentType.hls : null;
      await controller.prepare(iptv.url, contentType: contentType, playWhenReady: true);

      resolution = controller.value.resolution;
      aspectRatio = controller.value.aspectRatio;
    } catch (e, st) {
      _logger.handle(e, st);
      state = PlayerState.failed;
      rethrow;
    }
  }
}
