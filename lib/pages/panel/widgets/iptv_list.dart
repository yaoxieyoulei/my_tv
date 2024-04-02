import 'dart:async';
import 'dart:ui';

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
      _groupScrollController.jumpTo(clampDouble(
        _selectedIptv.groupIdx * 180.h,
        _groupScrollController.position.minScrollExtent,
        _groupScrollController.position.maxScrollExtent,
      ));

      _listScrollController.jumpTo(clampDouble(
        (_selectedIptv.idx - 1) * 300.w,
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
      clampDouble(
        _selectedIptv.groupIdx * 180.h,
        _groupScrollController.position.minScrollExtent,
        _groupScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    await _listScrollController.animateTo(
      clampDouble(
        (_selectedIptv.idx - 1) * 300.w,
        _listScrollController.position.minScrollExtent,
        _listScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
      height: 280.h,
      child: Observer(
        builder: (_) => ListView.separated(
          controller: _groupScrollController,
          itemBuilder: (context, index) {
            final group = iptvStore.iptvGroupList[index];

            return SizedBox(
              height: 160.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 30.sp,
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
          itemCount: iptvStore.iptvGroupList.length,
        ),
      ),
    );
  }

  /// 直播源列表
  Widget _buildIptvList(IptvGroup group) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        controller: group.idx == _selectedIptv.groupIdx ? _listScrollController : null,
        itemBuilder: (context, index) => _buildIptvItem(group.list[index]),
        separatorBuilder: (context, idx) => SizedBox(width: 20.w),
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
          width: 280.w,
          decoration: BoxDecoration(
            color: _selectedIptv == iptv
                ? Theme.of(context).colorScheme.onBackground
                : Theme.of(context).colorScheme.background.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20).r,
          ),
          child: Center(
            child: Text(
              textAlign: TextAlign.center,
              iptv.name.replaceFirst(' ', '\n'),
              style: TextStyle(
                color: _selectedIptv == iptv
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onBackground,
                fontSize: 36.sp,
              ),
            ),
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
        if (event.runtimeType != KeyUpEvent) return;

        setState(() {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _changeSelectedIptv(iptvStore.getPrevGroupIptv(iptv: _selectedIptv));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _changeSelectedIptv(iptvStore.getNextGroupIptv(iptv: _selectedIptv));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _changeSelectedIptv(iptvStore.getPrevIptv(iptv: _selectedIptv));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _changeSelectedIptv(iptvStore.getNextIptv(iptv: _selectedIptv));
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            iptvStore.currentIptv = _selectedIptv;
            Navigator.pop(context);
          }
        });
      },
    );
  }
}
