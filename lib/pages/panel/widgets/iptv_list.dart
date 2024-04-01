import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';

class PanelIPTVList extends StatefulWidget {
  const PanelIPTVList({super.key});

  @override
  State<PanelIPTVList> createState() => _PanelIPTVListState();
}

class _PanelIPTVListState extends State<PanelIPTVList> {
  final iptvStore = GetIt.I<IPTVStore>();

  final _focusNode = FocusNode();
  late IPTV _selectedIPTV;
  final _groupScrollController = ScrollController();
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _focusNode.requestFocus();
    _selectedIPTV = iptvStore.currentIPTV;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupScrollController.jumpTo(clampDouble(
        _selectedIPTV.groupIdx * 180.h,
        _groupScrollController.position.minScrollExtent,
        _groupScrollController.position.maxScrollExtent,
      ));

      _listScrollController.jumpTo(clampDouble(
        (_selectedIPTV.idx - 1) * 300.w,
        _listScrollController.position.minScrollExtent,
        _listScrollController.position.maxScrollExtent,
      ));
    });
  }

  Future<void> _changeSelectedIPTV(IPTV iptv) async {
    setState(() {
      _selectedIPTV = iptv;
    });

    await _groupScrollController.animateTo(
      clampDouble(
        _selectedIPTV.groupIdx * 180.h,
        _groupScrollController.position.minScrollExtent,
        _groupScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    await _listScrollController.animateTo(
      clampDouble(
        (_selectedIPTV.idx - 1) * 300.w,
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
        _buildIPTVGroupList(),
        _buildKeyboardListener(),
      ],
    );
  }

  /// 直播源分组列表
  Widget _buildIPTVGroupList() {
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
                  _buildIPTVList(group),
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
  Widget _buildIPTVList(IPTVGroup group) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        controller: group.idx == _selectedIPTV.groupIdx ? _listScrollController : null,
        itemBuilder: (context, index) => _buildIPTVItem(group.list[index]),
        separatorBuilder: (context, idx) => SizedBox(width: 20.w),
        itemCount: group.list.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  /// 单个直播源
  Widget _buildIPTVItem(IPTV iptv) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _changeSelectedIPTV(iptv);
        iptvStore.currentIPTV = iptv;
        Navigator.pop(context);
      },
      child: Container(
          width: 280.w,
          decoration: BoxDecoration(
            color: _selectedIPTV == iptv
                ? Theme.of(context).colorScheme.onBackground
                : Theme.of(context).colorScheme.background.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20).r,
          ),
          child: Center(
            child: Text(
              textAlign: TextAlign.center,
              iptv.name.replaceFirst(' ', '\n'),
              style: TextStyle(
                color: _selectedIPTV == iptv
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
            _changeSelectedIPTV(iptvStore.getPrevGroupIPTV(iptv: _selectedIPTV));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _changeSelectedIPTV(iptvStore.getNextGroupIPTV(iptv: _selectedIPTV));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _changeSelectedIPTV(iptvStore.getPrevIPTV(iptv: _selectedIPTV));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _changeSelectedIPTV(iptvStore.getNextIPTV(iptv: _selectedIPTV));
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            iptvStore.currentIPTV = _selectedIPTV;
            Navigator.pop(context);
          }
        });
      },
    );
  }
}
