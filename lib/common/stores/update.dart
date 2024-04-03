import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'package:my_tv/common/index.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'update.g.dart';

class UpdateStore = UpdateStoreBase with _$UpdateStore;

int _compareVersions(String version1, String version2) {
  List<int> v1 = version1.split('.').map(int.parse).toList();
  List<int> v2 = version2.split('.').map(int.parse).toList();

  // 对比主版本号、次版本号和修订号
  for (int i = 0; i < 3; i++) {
    if (v1[i] < v2[i]) {
      return -1;
    } else if (v1[i] > v2[i]) {
      return 1;
    }
  }

  // 如果三个号码都相同，则版本相同
  return 0;
}

final _logger = LoggerUtil.create(['更新']);

abstract class UpdateStoreBase with Store {
  /// 最新release
  @observable
  var latestRelease = GithubRelease(tagName: 'v0.0.0', downloadUrl: '', description: '');

  /// 当前版本
  @observable
  String currentVersion = '0.0.0';

  /// 发现更新
  @computed
  bool get needUpdate => _compareVersions(latestRelease.tagName.substring(1), currentVersion) > 0;

  /// 获取最新release
  @action
  Future<void> refreshLatestRelease() async {
    _logger.debug('开始检查更新: ${Constants.githubReleaseLatest}');

    final packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;

    final result = jsonDecode(await RequestUtil.get(Constants.githubReleaseLatest));
    latestRelease = GithubRelease(
      tagName: result['tag_name'],
      downloadUrl: result['assets'][0]['browser_download_url'],
      description: result['body'],
    );

    _logger.debug('检查更新成功: $latestRelease');
  }
}
