// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlayerStore on PlayerStoreBase, Store {
  late final _$aspectRatioAtom = Atom(name: 'PlayerStoreBase.aspectRatio', context: context);

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

  late final _$resolutionAtom = Atom(name: 'PlayerStoreBase.resolution', context: context);

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

  late final _$stateAtom = Atom(name: 'PlayerStoreBase.state', context: context);

  @override
  PlayerState get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(PlayerState value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$initAsyncAction = AsyncAction('PlayerStoreBase.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$playIptvAsyncAction = AsyncAction('PlayerStoreBase.playIptv', context: context);

  @override
  Future<void> playIptv(Iptv iptv) {
    return _$playIptvAsyncAction.run(() => super.playIptv(iptv));
  }

  @override
  String toString() {
    return '''
aspectRatio: ${aspectRatio},
resolution: ${resolution},
state: ${state}
    ''';
  }
}
