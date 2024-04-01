// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlayerStore on PlayerStoreBase, Store {
  late final _$controllerAtom =
      Atom(name: 'PlayerStoreBase.controller', context: context);

  @override
  VideoPlayerController get controller {
    _$controllerAtom.reportRead();
    return super.controller;
  }

  @override
  set controller(VideoPlayerController value) {
    _$controllerAtom.reportWrite(value, super.controller, () {
      super.controller = value;
    });
  }

  late final _$aspectRatioAtom =
      Atom(name: 'PlayerStoreBase.aspectRatio', context: context);

  @override
  double? get aspectRatio {
    _$aspectRatioAtom.reportRead();
    return super.aspectRatio;
  }

  @override
  set aspectRatio(double? value) {
    _$aspectRatioAtom.reportWrite(value, super.aspectRatio, () {
      super.aspectRatio = value;
    });
  }

  late final _$resolutionAtom =
      Atom(name: 'PlayerStoreBase.resolution', context: context);

  @override
  Size get resolution {
    _$resolutionAtom.reportRead();
    return super.resolution;
  }

  @override
  set resolution(Size value) {
    _$resolutionAtom.reportWrite(value, super.resolution, () {
      super.resolution = value;
    });
  }

  late final _$playIPTVAsyncAction =
      AsyncAction('PlayerStoreBase.playIPTV', context: context);

  @override
  Future<void> playIPTV(IPTV iptv) {
    return _$playIPTVAsyncAction.run(() => super.playIPTV(iptv));
  }

  @override
  String toString() {
    return '''
controller: ${controller},
aspectRatio: ${aspectRatio},
resolution: ${resolution}
    ''';
  }
}
