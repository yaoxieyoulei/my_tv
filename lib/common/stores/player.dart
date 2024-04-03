import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';
import 'package:video_player/video_player.dart';

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
  /// 播放器
  @observable
  VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(''));

  /// 宽高比
  @observable
  double? aspectRatio;

  /// 分辨率
  @observable
  Size resolution = Size.zero;

  /// 播放状态
  @observable
  PlayerState state = PlayerState.waiting;

  /// 播放直播源
  @action
  Future<void> playIptv(Iptv iptv) async {
    try {
      _logger.debug('播放直播源: $iptv');
      state = PlayerState.waiting;

      // TODO 切换频道时存在黑屏问题
      await controller.pause();
      await controller.dispose();

      controller = VideoPlayerController.networkUrl(Uri.parse(iptv.url));
      await controller.initialize();
      await controller.play();

      state = PlayerState.playing;
      aspectRatio = controller.value.aspectRatio;
      resolution = controller.value.size;
    } catch (e, st) {
      _logger.handle(e, st);
      state = PlayerState.failed;
      rethrow;
    }
  }
}
