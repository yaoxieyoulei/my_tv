import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:my_tv/common/index.dart';

final _logger = LoggerUtil.create(['Media3PlayerController']);

AndroidMedia3Player _instance = AndroidMedia3Player();
AndroidMedia3Player? _lastPlayerPlatform;

AndroidMedia3Player get _playerPlatform {
  final currentInstance = _instance;
  if (_lastPlayerPlatform != currentInstance) {
    currentInstance.initialize();
    _lastPlayerPlatform = currentInstance;
  }
  return currentInstance;
}

class Media3PlayerController extends ValueNotifier<Media3PlayerValue> {
  int _textureId = -1;
  int get textureId => _textureId;

  Media3PlayerController() : super(Media3PlayerValue());

  Future<void> create() async {
    _textureId = await _playerPlatform.create();

    _playerPlatform.eventsFor(textureId).listen(_listenEventData, onError: _listenEventError);
  }

  void _listenEventData(Media3PlayerEvent event) {
    switch (event.eventType) {
      case Media3PlayerEventType.stateBuffering:
        value = value.copyWith(isBuffering: event.isBuffering);

      case Media3PlayerEventType.stateEnded:
        value = value.copyWith(state: Media3PlayerState.completed);

      case Media3PlayerEventType.stateIdle:
        value = value.copyWith(state: Media3PlayerState.idle);

      case Media3PlayerEventType.stateReady:
        value = value.copyWith(state: Media3PlayerState.prepared);

      case Media3PlayerEventType.videoSizeChanged:
        value = value.copyWith(
          resolution: event.videoSize,
          aspectRatio: event.videoSize != null ? (event.videoSize!.width / event.videoSize!.height) : 0,
        );

      case Media3PlayerEventType.isPlayingChanged:
        value = value.copyWith(
          state: event.isPlaying == true ? Media3PlayerState.started : Media3PlayerState.paused,
        );

      default:
        {}
    }
  }

  void _listenEventError(Object? error) {
    _logger.error(error);

    value = value.copyWith(state: Media3PlayerState.error);
  }

  Future<void> prepare(
    String dataSource, {
    Media3PlayerVideoContentType? contentType,
    bool? playWhenReady,
  }) async {
    if (_textureId == -1) return;

    await _playerPlatform.prepare(
      _textureId,
      dataSource,
      contentType: contentType,
      playWhenReady: playWhenReady,
    );

    final preparedCompleter = Completer();

    preparedListener() {
      if (value.state == Media3PlayerState.prepared) {
        preparedCompleter.complete();
      } else if (value.state == Media3PlayerState.error) {
        preparedCompleter.completeError('无法播放视频');
      }
    }

    addListener(preparedListener);
    await preparedCompleter.future.whenComplete(() => removeListener(preparedListener));
  }

  Future<void> play() async {
    if (_textureId == -1) return;

    await _playerPlatform.play(_textureId);
  }

  Future<void> pause() async {
    if (_textureId == -1) return;

    await _playerPlatform.pause(_textureId);
  }

  Future<void> stop() async {
    if (_textureId == -1) return;

    await _playerPlatform.stop(_textureId);
  }

  @override
  Future<void> dispose() async {
    if (_textureId == -1) return;

    await _playerPlatform.dispose(_textureId);
    super.dispose();
  }
}

class Media3PlayerValue {
  Media3PlayerValue({
    this.state = Media3PlayerState.idle,
    this.resolution = Size.zero,
    this.aspectRatio = 0.0,
    this.isBuffering = false,
  });

  final Media3PlayerState state;
  final Size resolution;
  final double aspectRatio;
  final bool isBuffering;

  Media3PlayerValue copyWith({
    Media3PlayerState? state,
    Size? resolution,
    double? aspectRatio,
    bool? isBuffering,
  }) {
    return Media3PlayerValue(
      state: state ?? this.state,
      resolution: resolution ?? this.resolution,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

enum Media3PlayerVideoContentType {
  dash,
  ss,
  hls,
  other;
}

enum Media3PlayerEventType {
  stateBuffering,
  stateEnded,
  stateIdle,
  stateReady,
  videoSizeChanged,
  isPlayingChanged,
  unknown,
}

enum Media3PlayerState {
  idle,
  prepared,
  started,
  paused,
  completed,
  error,
}

class Media3PlayerEvent {
  final Media3PlayerEventType eventType;
  final bool? isBuffering;
  final Size? videoSize;
  final bool? isPlaying;

  Media3PlayerEvent({
    required this.eventType,
    this.isBuffering,
    this.videoSize,
    this.isPlaying,
  });
}
