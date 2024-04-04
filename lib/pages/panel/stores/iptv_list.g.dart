// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iptv_list.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$IptvListStore on IptvListStoreBase, Store {
  late final _$selectedIptvAtom =
      Atom(name: 'IptvListStoreBase.selectedIptv', context: context);

  @override
  Iptv get selectedIptv {
    _$selectedIptvAtom.reportRead();
    return super.selectedIptv;
  }

  @override
  set selectedIptv(Iptv value) {
    _$selectedIptvAtom.reportWrite(value, super.selectedIptv, () {
      super.selectedIptv = value;
    });
  }

  @override
  String toString() {
    return '''
selectedIptv: ${selectedIptv}
    ''';
  }
}
