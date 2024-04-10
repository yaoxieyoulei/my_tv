import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/common/plugins/media3_player/messages.g.dart',
  kotlinOut: 'android/app/src/main/kotlin/com/example/my_tv/plugins/media3player/Messages.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.example.my_tv.plugins.media3player',
  ),
))
class TextureMessage {
  TextureMessage(this.textureId);
  int textureId;
}

class PrepareMessage {
  PrepareMessage(this.textureId, this.dataSource);

  int textureId;
  String dataSource;
  int? contentType;
  bool? playWhenReady;
}

class PlayMessage {
  PlayMessage(this.textureId);
  int textureId;
}

class PauseMessage {
  PauseMessage(this.textureId);
  int textureId;
}

class StopMessage {
  StopMessage(this.textureId);
  int textureId;
}

class DisposeMessage {
  DisposeMessage(this.textureId);
  int textureId;
}

class GetEncoderListMessage {
  GetEncoderListMessage(this.encoders);
  String encoders;
}

@HostApi()
abstract class AndroidMedia3PlayerApi {
  void initialize();
  TextureMessage create();
  void prepare(PrepareMessage msg);
  void play(PlayMessage msg);
  void pause(PauseMessage msg);
  void stop(StopMessage msg);
  void dispose(DisposeMessage msg);
}
