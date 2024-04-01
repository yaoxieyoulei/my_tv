import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';
import 'package:video_player/video_player.dart';

part 'player.g.dart';

class PlayerStore = PlayerStoreBase with _$PlayerStore;

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

  /// 播放直播源
  @action
  Future<void> playIPTV(IPTV iptv) async {
    try {
      await controller.pause();
      await controller.dispose();

      controller = VideoPlayerController.networkUrl(Uri.parse(iptv.url));
      await controller.initialize();
      await controller.play();

      aspectRatio = controller.value.aspectRatio;
      resolution = controller.value.size;
    } catch (err) {
      Global.logger.e("播放失败", error: err);
    }
  }
}
