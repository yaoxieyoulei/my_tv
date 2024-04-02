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

abstract class UpdateStoreBase with Store {
  /// 最新release
  @observable
  var latestRelease = GithubRelease(tagName: 'v0.0.0', downloadUrl: '', description: '');

  /// 当前版本
  @observable
  String currentVersion = '0.0.0';

  /// 需要更新
  @computed
  bool get needUpdate => _compareVersions(latestRelease.tagName.substring(1), currentVersion) > 0;

  /// 获取最新release
  @action
  Future<void> refreshLatestRelease() async {
    Global.logger.debug('[更新] 开始检查更新: ${Constants.githubReleaseLatest}');

    final packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;

    final response = await Global.dio.get(Constants.githubReleaseLatest);

    if (response.statusCode != 200) {
      final err = '[更新] 检查更新失败: ${response.statusCode}';
      Global.logger.handle(err);
      throw Exception(err);
    }

    latestRelease = GithubRelease(
      tagName: response.data['tag_name'],
      downloadUrl: response.data['assets'][0]['browser_download_url'],
      description: response.data['body'],
    );

    Global.logger.debug('[更新] 检查更新成功: $latestRelease');
  }
}
