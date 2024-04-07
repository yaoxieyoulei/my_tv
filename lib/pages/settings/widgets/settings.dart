import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';
import 'package:my_tv/pages/settings/widgets/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class SettingGroup {
  final String name;
  final List<SettingItem> items;

  SettingGroup({required this.name, required this.items});
}

class SettingItem {
  final String title;
  final String Function() value;
  final String Function() description;
  final void Function() onTap;
  final void Function()? onLongTap;

  SettingItem({
    required this.title,
    required this.value,
    required this.description,
    required this.onTap,
    this.onLongTap,
  });
}

class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key});

  @override
  State<SettingsMain> createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  final iptvStore = GetIt.I<IptvStore>();
  final updateStore = GetIt.I<UpdateStore>();

  late final List<SettingItem> _settingItemList;
  String _displayMode = '平台不支持';

  @override
  void initState() {
    super.initState();
    refreshSettingGroupList();

    HttpServerUtil.init().then((_) => setState(() {}));
    FlutterDisplayMode.active.then((value) {
      setState(() {
        _displayMode = value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190.w + 20.h,
      child: TwoDimensionListView(
        size: (rowHeight: 190.w, colWidth: 400.w),
        scrollOffset: (row: 0, col: -1),
        gap: (row: 20.h, col: 20.w),
        itemCount: (
          row: 1,
          col: (_) => _settingItemList.length,
        ),
        onSelect: (position) => setState(() {
          _settingItemList.elementAtOrNull(position.col)?.onTap();
        }),
        onLongSelect: (position) => setState(() {
          _settingItemList.elementAtOrNull(position.col)?.onLongTap?.call();
        }),
        itemBuilder: (context, position, isSelected) {
          final item = _settingItemList[position.col];

          return _buildSettingItem(item, isSelected);
        },
      ),
    );
  }

  Widget _buildSettingItem(SettingItem item, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(30).r,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.onBackground
            : Theme.of(context).colorScheme.background.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20).r,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context).colorScheme.onBackground,
                  fontSize: 30.sp,
                ),
              ),
              Text(
                item.value(),
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context).colorScheme.onBackground,
                  fontSize: 30.sp,
                ),
              ),
            ],
          ),
          Text(
            item.description(),
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.onBackground,
              fontSize: 24.sp,
            ),
          )
        ],
      ),
    );
  }

  void refreshSettingGroupList() {
    final groupList = [
      SettingGroup(name: '应用', items: [
        SettingItem(
          title: '应用更新',
          value: () => updateStore.hasUpdate ? '新版本' : '无更新',
          description: () => '最新版本：${updateStore.latestRelease.tagName}',
          onTap: () {
            if (updateStore.hasUpdate) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(updateStore.latestRelease.tagName),
                  content: SingleChildScrollView(
                    child: Text(updateStore.latestRelease.description),
                  ),
                ),
              );
            } else {
              showToast('开始检测更新');
              updateStore.refreshLatestRelease().then((_) {
                if (!updateStore.hasUpdate) {
                  showToast('已是最新版本');
                } else {
                  setState(() {});
                }
              });
            }
          },
          onLongTap: () {
            updateStore.downloadAndInstall();
          },
        ),
        SettingItem(
          title: '开机自启',
          value: () => AppSettings.bootLaunch ? '启用' : '禁用',
          description: () => '下次重启生效',
          onTap: () {
            AppSettings.bootLaunch = !AppSettings.bootLaunch;
          },
        ),
      ]),
      SettingGroup(name: '控制', items: [
        SettingItem(
          title: '换台反转',
          value: () => IptvSettings.channelChangeFlip ? '反转' : '正常',
          description: () => IptvSettings.channelChangeFlip ? '方向键上：下一个频道\n方向键下：上一个频道' : '方向键上：上一个频道\n方向键下：下一个频道',
          onTap: () {
            IptvSettings.channelChangeFlip = !IptvSettings.channelChangeFlip;
          },
        ),
      ]),
      SettingGroup(name: '直播源', items: [
        SettingItem(
          title: '直播源精简',
          value: () => IptvSettings.iptvSourceSimplify ? '启用' : '禁用',
          description: () => IptvSettings.iptvSourceSimplify ? '显示精简直播源(仅央视、地方卫视)' : '显示完整直播源',
          onTap: () {
            IptvSettings.iptvSourceSimplify = !IptvSettings.iptvSourceSimplify;
            IptvSettings.epgCacheHash = 0;
            iptvStore.refreshIptvList().then((_) => setState(() {}));
          },
        ),
        SettingItem(
          title: '自定义直播源',
          value: () => IptvSettings.customIptvSource.isNotEmpty ? '已启用' : '未启用',
          description: () => '访问以下网址进行配置：${HttpServerUtil.serverUrl}',
          onTap: () {
            NavigatorUtil.push(
              context,
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onBackground,
                    borderRadius: BorderRadius.circular(20).r,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: 200.h,
                      width: 200.h,
                      child: PrettyQrView.data(
                        data: HttpServerUtil.serverUrl,
                        decoration: PrettyQrDecoration(
                          shape: PrettyQrSmoothSymbol(
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          onLongTap: () {
            if (IptvSettings.customIptvSource.isNotEmpty) {
              iptvStore.refreshIptvList().then((_) => setState(() {}));
            }
          },
        ),
        SettingItem(
          title: '直播源缓存',
          value: () => '24小时',
          description: () => IptvSettings.iptvSourceCacheTime > 0 ? "已缓存(点击清除缓存)" : "未缓存",
          onTap: () {
            if (IptvSettings.iptvSourceCacheTime > 0) {
              IptvSettings.iptvSourceCacheTime = 0;
              iptvStore.refreshIptvList().then((_) => setState(() {}));
            }
          },
        ),
      ]),
      SettingGroup(name: '节目单', items: [
        SettingItem(
          title: '节目单',
          value: () => IptvSettings.epgEnable ? '启用' : '禁用',
          description: () => '首次加载时可能会有跳帧风险',
          onTap: () {
            IptvSettings.epgEnable = !IptvSettings.epgEnable;
            iptvStore.refreshEpgList().then((_) => setState(() {}));
          },
        ),
        SettingItem(
          title: '节目单缓存',
          value: () => '当天',
          description: () => IptvSettings.epgXmlCacheTime > 0 ? "已缓存(点击清除缓存)" : "未缓存",
          onTap: () {
            if (IptvSettings.epgXmlCacheTime > 0) {
              IptvSettings.epgXmlCacheTime = 0;
              IptvSettings.epgCacheHash = 0;
              iptvStore.refreshEpgList().then((_) => setState(() {}));
            }
          },
        ),
      ]),
      SettingGroup(name: '调试', items: [
        SettingItem(
          title: '显示FPS',
          value: () => ShowFPS.isShowing ? '启用' : '禁用',
          description: () => '显示当前帧率',
          onTap: () {
            ShowFPS.toggle(context);
          },
        ),
        SettingItem(
          title: '延时渲染',
          value: () => DebugSettings.delayRender ? '启用' : '禁用',
          description: () => '对各个组件延时渲染，减少卡顿掉帧',
          onTap: () {
            DebugSettings.delayRender = !DebugSettings.delayRender;
          },
        ),
        SettingItem(
          title: '显示模式',
          value: () => '',
          description: () => _displayMode.toString(),
          onTap: () {},
        ),
        SettingItem(
          title: '日志',
          value: () => '${LoggerUtil.history.length}条',
          description: () => '点击查看日志',
          onTap: () {
            if (LoggerUtil.history.isNotEmpty) {
              NavigatorUtil.push(context, SettingsLogger());
            } else {
              showToast('无日志记录');
            }
          },
        ),
      ]),
    ];

    _settingItemList = groupList.expand((element) => element.items).toList();
  }
}
