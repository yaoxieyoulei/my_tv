import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';
import 'package:my_tv/pages/panel/stores/iptv_list.dart';

class PanelIptvList extends StatefulWidget {
  const PanelIptvList({super.key});

  @override
  State<PanelIptvList> createState() => _PanelIptvListState();
}

class _PanelIptvListState extends State<PanelIptvList> {
  final iptvStore = GetIt.I<IptvStore>();
  final iptvListStore = IptvListStore();

  late final ScrollController _groupScrollController;
  late final ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    iptvListStore.selectedIptv = iptvStore.currentIptv;

    _groupScrollController = ScrollController(initialScrollOffset: (iptvListStore.selectedIptv.groupIdx * 140.h));
    _listScrollController = ScrollController(initialScrollOffset: ((iptvListStore.selectedIptv.idx - 1) * 280.w));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupScrollController.jumpTo((iptvListStore.selectedIptv.groupIdx * 140.h).clamp(
        _groupScrollController.position.minScrollExtent,
        _groupScrollController.position.maxScrollExtent,
      ));

      _listScrollController.jumpTo(((iptvListStore.selectedIptv.idx - 1) * 280.w).clamp(
        _listScrollController.position.minScrollExtent,
        _listScrollController.position.maxScrollExtent,
      ));
    });
  }

  Future<void> _changeSelectedIptv(Iptv iptv) async {
    iptvListStore.selectedIptv = iptv;

    await _groupScrollController.animateTo(
      (iptvListStore.selectedIptv.groupIdx * 140.h).clamp(
        _groupScrollController.position.minScrollExtent,
        _groupScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );

    await _listScrollController.animateTo(
      ((iptvListStore.selectedIptv.idx - 1) * 280.w).clamp(
        _listScrollController.position.minScrollExtent,
        _listScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildIptvGroupList(),
        _buildKeyboardListener(),
      ],
    );
  }

  /// 直播源分组列表
  Widget _buildIptvGroupList() {
    return SizedBox(
      height: 240.h,
      child: Observer(
        builder: (_) => ListView.separated(
          controller: _groupScrollController,
          itemBuilder: (context, index) {
            if (index == iptvStore.iptvGroupList.length) {
              return Container();
            }

            final group = iptvStore.iptvGroupList[index];

            return SizedBox(
              height: 120.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分组名称
                  Text(
                    group.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildIptvList(group),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 20.h),
          itemCount: iptvStore.iptvGroupList.length + 1,
        ),
      ),
    );
  }

  /// 直播源列表
  Widget _buildIptvList(IptvGroup group) {
    return SizedBox(
      height: 80.h,
      child: Observer(
        builder: (_) => ListView.separated(
          controller: group.idx == iptvListStore.selectedIptv.groupIdx ? _listScrollController : null,
          itemBuilder: (context, index) {
            if (index == group.list.length) {
              return Container();
            }

            return _buildIptvItem(group.list[index]);
          },
          separatorBuilder: (context, idx) => SizedBox(width: 20.w),
          itemCount: group.list.length + 1,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  /// 单个直播源
  Widget _buildIptvItem(Iptv iptv) {
    return Observer(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _changeSelectedIptv(iptv);
          iptvStore.currentIptv = iptv;
          Navigator.pop(context);
        },
        child: Container(
            width: 260.w,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10).r,
            decoration: BoxDecoration(
              color: iptvListStore.selectedIptv == iptv
                  ? Theme.of(context).colorScheme.onBackground
                  : Theme.of(context).colorScheme.background.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20).r,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  iptv.name,
                  style: TextStyle(
                    color: iptvListStore.selectedIptv == iptv
                        ? Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.onBackground,
                    fontSize: 30.sp,
                  ),
                  maxLines: 1,
                ),
                Text(
                  iptvStore.getIptvProgrammes(iptv).current,
                  style: TextStyle(
                    color: iptvListStore.selectedIptv == iptv
                        ? Theme.of(context).colorScheme.background.withOpacity(0.8)
                        : Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                    fontSize: 24.sp,
                  ),
                  maxLines: 1,
                ),
              ],
            )),
      ),
    );
  }

  /// 键盘事件监听
  Widget _buildKeyboardListener() {
    return EasyKeyboardListener(
      autofocus: true,
      onKeyTap: {
        LogicalKeyboardKey.arrowUp: () {
          _changeSelectedIptv(iptvStore.getPrevGroupIptv(iptvListStore.selectedIptv));
        },
        LogicalKeyboardKey.arrowDown: () {
          _changeSelectedIptv(iptvStore.getNextGroupIptv(iptvListStore.selectedIptv));
        },
        LogicalKeyboardKey.arrowLeft: () {
          _changeSelectedIptv(iptvStore.getPrevIptv(iptvListStore.selectedIptv));
        },
        LogicalKeyboardKey.arrowRight: () {
          _changeSelectedIptv(iptvStore.getNextIptv(iptvListStore.selectedIptv));
        },
        LogicalKeyboardKey.select: () {
          iptvStore.currentIptv = iptvListStore.selectedIptv;
          Navigator.pop(context);
        },
      },
      child: Container(),
    );
  }
}
