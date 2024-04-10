import 'package:flutter/material.dart';
import 'package:my_tv/common/index.dart';

class Media3Player extends StatefulWidget {
  const Media3Player({super.key, required this.controller});

  final Media3PlayerController controller;

  @override
  State<Media3Player> createState() => _Media3PlayerState();
}

class _Media3PlayerState extends State<Media3Player> {
  late int _textureId;

  _listener() {
    final int newTextureId = widget.controller.textureId;
    if (newTextureId != _textureId) {
      setState(() {
        _textureId = newTextureId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(Media3Player oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_listener);
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    if (_textureId == -1) return Container();

    return Texture(textureId: _textureId);
  }
}
