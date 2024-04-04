import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';

part 'iptv_list.g.dart';

class IptvListStore = IptvListStoreBase with _$IptvListStore;

abstract class IptvListStoreBase with Store {
  @observable
  Iptv selectedIptv = Iptv.empty;
}
