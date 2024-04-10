import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tv/common/index.dart';

import 'messages.g.dart';

/// Android Media3 ExoPlayer 播放器
class AndroidMedia3Player {
  final _api = AndroidMedia3PlayerApi();

  /// 初始化（销毁全部播放器）
  Future<void> initialize() {
    return _api.initialize();
  }

  /// 创建播放器实例
  Future<int> create() async {
    final response = await _api.create();
    return response.textureId;
  }

  /// 设置播放地址
  Future<void> prepare(
    int textureId,
    String dataSource, {
    Media3PlayerVideoContentType? contentType,
    bool? playWhenReady,
  }) {
    return _api.prepare(PrepareMessage(
      textureId: textureId,
      dataSource: dataSource,
      contentType: contentType != null ? _videoContentTypeMap[contentType] : null,
      playWhenReady: playWhenReady,
    ));
  }

  /// 播放
  Future<void> play(int textureId) {
    return _api.play(PlayMessage(textureId: textureId));
  }

  /// 暂停
  Future<void> pause(int textureId) {
    return _api.pause(PauseMessage(textureId: textureId));
  }

  /// 停止
  Future<void> stop(int textureId) {
    return _api.stop(StopMessage(textureId: textureId));
  }

  /// 销毁
  Future<void> dispose(int textureId) {
    return _api.dispose(DisposeMessage(textureId: textureId));
  }

  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel('my_tv.yogiczy.top/media3Player/media3Events$textureId');
  }

  Stream<Media3PlayerEvent> eventsFor(int textureId) {
    return _eventChannelFor(textureId).receiveBroadcastStream().map((event) {
      event = event as Map<dynamic, dynamic>;
      switch (event['event']) {
        case "stateBuffering":
          return Media3PlayerEvent(
            eventType: Media3PlayerEventType.stateBuffering,
            isBuffering: event['isBuffering'],
          );

        case "stateEnded":
          return Media3PlayerEvent(eventType: Media3PlayerEventType.stateEnded);

        case "stateIdle":
          return Media3PlayerEvent(eventType: Media3PlayerEventType.stateIdle);

        case "stateReady":
          return Media3PlayerEvent(eventType: Media3PlayerEventType.stateReady);

        case "videoSizeChanged":
          return Media3PlayerEvent(
            eventType: Media3PlayerEventType.videoSizeChanged,
            videoSize: Size(
              (event['width'] as int).toDouble(),
              (event['height'] as int).toDouble(),
            ),
          );

        case "isPlayingChanged":
          return Media3PlayerEvent(
            eventType: Media3PlayerEventType.isPlayingChanged,
            isPlaying: event['isPlaying'],
          );

        default:
          return Media3PlayerEvent(eventType: Media3PlayerEventType.unknown);
      }
    });
  }

  static final _videoContentTypeMap = {
    Media3PlayerVideoContentType.dash: 0,
    Media3PlayerVideoContentType.ss: 1,
    Media3PlayerVideoContentType.hls: 2,
    Media3PlayerVideoContentType.other: 4,
  };
}
