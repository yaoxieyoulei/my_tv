// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iptv.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$IPTVStore on IPTVStoreBase, Store {
  late final _$iptvGroupListAtom =
      Atom(name: 'IPTVStoreBase.iptvGroupList', context: context);

  @override
  List<IPTVGroup> get iptvGroupList {
    _$iptvGroupListAtom.reportRead();
    return super.iptvGroupList;
  }

  @override
  set iptvGroupList(List<IPTVGroup> value) {
    _$iptvGroupListAtom.reportWrite(value, super.iptvGroupList, () {
      super.iptvGroupList = value;
    });
  }

  late final _$iptvListAtom =
      Atom(name: 'IPTVStoreBase.iptvList', context: context);

  @override
  List<IPTV> get iptvList {
    _$iptvListAtom.reportRead();
    return super.iptvList;
  }

  @override
  set iptvList(List<IPTV> value) {
    _$iptvListAtom.reportWrite(value, super.iptvList, () {
      super.iptvList = value;
    });
  }

  late final _$currentIPTVAtom =
      Atom(name: 'IPTVStoreBase.currentIPTV', context: context);

  @override
  IPTV get currentIPTV {
    _$currentIPTVAtom.reportRead();
    return super.currentIPTV;
  }

  @override
  set currentIPTV(IPTV value) {
    _$currentIPTVAtom.reportWrite(value, super.currentIPTV, () {
      super.currentIPTV = value;
    });
  }

  late final _$iptvInfoVisibleAtom =
      Atom(name: 'IPTVStoreBase.iptvInfoVisible', context: context);

  @override
  bool get iptvInfoVisible {
    _$iptvInfoVisibleAtom.reportRead();
    return super.iptvInfoVisible;
  }

  @override
  set iptvInfoVisible(bool value) {
    _$iptvInfoVisibleAtom.reportWrite(value, super.iptvInfoVisible, () {
      super.iptvInfoVisible = value;
    });
  }

  late final _$channelNoAtom =
      Atom(name: 'IPTVStoreBase.channelNo', context: context);

  @override
  String get channelNo {
    _$channelNoAtom.reportRead();
    return super.channelNo;
  }

  @override
  set channelNo(String value) {
    _$channelNoAtom.reportWrite(value, super.channelNo, () {
      super.channelNo = value;
    });
  }

  late final _$refreshIPTVListAsyncAction =
      AsyncAction('IPTVStoreBase.refreshIPTVList', context: context);

  @override
  Future<void> refreshIPTVList() {
    return _$refreshIPTVListAsyncAction.run(() => super.refreshIPTVList());
  }

  @override
  String toString() {
    return '''
iptvGroupList: ${iptvGroupList},
iptvList: ${iptvList},
currentIPTV: ${currentIPTV},
iptvInfoVisible: ${iptvInfoVisible},
channelNo: ${channelNo}
    ''';
  }
}
