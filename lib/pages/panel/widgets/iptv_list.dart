import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';

class PanelIptvList extends StatefulWidget {
  const PanelIptvList({super.key});

  @override
  State<PanelIptvList> createState() => _PanelIptvListState();
}

class _PanelIptvListState extends State<PanelIptvList> {
  final iptvStore = GetIt.I<IptvStore>();

  final _focusNode = FocusNode();
  late Iptv _selectedIptv;
  final _groupScrollController = ScrollController();
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _focusNode.requestFocus();
    _selectedIptv = iptvStore.currentIptv;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupScrollController.jumpTo((_selectedIptv.groupIdx * 140.h).clamp(
        _groupScrollController.position.minScrollExtent,
        _groupScrollController.position.maxScrollExtent,
      ));

      _listScrollController.jumpTo(((_selectedIptv.idx - 1) * 280.w).clamp(
        _listScrollController.position.minScrollExtent,
        _listScrollController.position.maxScrollExtent,
      ));
    });
  }

  Future<void> _changeSelectedIptv(Iptv iptv) async {
    setState(() {
      _selectedIptv = iptv;
    });

    await _groupScrollController.animateTo(
      (_selectedIptv.groupIdx * 140.h).clamp(
        _groupScrollController.position.minScrollExtent,
        _groupScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );

    await _listScrollController.animateTo(
      ((_selectedIptv.idx - 1) * 280.w).clamp(
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
        builder: (_) => SliverListView.separated(
          controller: _groupScrollController,
          itemBuilder: (context, index) {
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
          endSeparator: true,
          itemCount: iptvStore.iptvGroupList.length,
        ),
      ),
    );
  }

  /// 直播源列表
  Widget _buildIptvList(IptvGroup group) {
    return SizedBox(
      height: 80.h,
      child: SliverListView.separated(
        controller: group.idx == _selectedIptv.groupIdx ? _listScrollController : null,
        itemBuilder: (context, index) => _buildIptvItem(group.list[index]),
        separatorBuilder: (context, idx) => SizedBox(width: 20.w),
        endSeparator: true,
        itemCount: group.list.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  /// 单个直播源
  Widget _buildIptvItem(Iptv iptv) {
    return GestureDetector(
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
            color: _selectedIptv == iptv
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
                  color: _selectedIptv == iptv
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context).colorScheme.onBackground,
                  fontSize: 30.sp,
                ),
                maxLines: 1,
              ),
              Observer(
                builder: (_) => Text(
                  iptvStore.getIptvProgrammes(iptv).current,
                  style: TextStyle(
                    color: _selectedIptv == iptv
                        ? Theme.of(context).colorScheme.background.withOpacity(0.8)
                        : Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                    fontSize: 24.sp,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          )),
    );
  }

  /// 键盘事件监听
  Widget _buildKeyboardListener() {
    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      child: Container(),
      onKeyEvent: (event) {
        if (event.runtimeType == KeyUpEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _changeSelectedIptv(iptvStore.getPrevGroupIptv(_selectedIptv));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _changeSelectedIptv(iptvStore.getNextGroupIptv(_selectedIptv));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _changeSelectedIptv(iptvStore.getPrevIptv(_selectedIptv));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _changeSelectedIptv(iptvStore.getNextIptv(_selectedIptv));
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            iptvStore.currentIptv = _selectedIptv;
            Navigator.pop(context);
          }
        }
      },
    );
  }
}
