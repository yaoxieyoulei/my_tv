import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_tv/common/index.dart';
import 'package:my_tv/pages/live/widgets/listen_gesture.dart';
import 'package:my_tv/pages/live/widgets/listen_keyboard.dart';
import 'package:video_player/video_player.dart';

import 'index.dart';

class LivePage extends GetView<LiveController> {
  const LivePage({super.key});

  // 主视图
  Widget _buildView() {
    return ListenKeyboard(
      onKeyArrowUp: () => controller.playPrevIPTV(),
      onKeyArrowDown: () => controller.playNextIPTV(),
      onKeySelect: () => _showPanel(),
      onKeyDigit: (digit) => controller.inputIPTVChannel(digit),
      child: ListenGesture(
        onTap: () => _showPanel(),
        onDragDown: () => controller.playPrevIPTV(),
        onDragUp: () => controller.playNextIPTV(),
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildPlayer(),
              _buildIPTVIdxInput(),
              Obx(() => controller.tempPanelVisible.value ? _buildPanel(showIPTVGroupList: false) : Container()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveController>(
      init: LiveController(),
      id: "live",
      builder: (_) {
        return Scaffold(
          body: SafeArea(
            child: Obx(() => _buildView()),
          ),
        );
      },
    );
  }

  Widget _buildPlayer() {
    Widget child = Container();

    if (controller.playerState.value == PlayState.playing) {
      child = Obx(() =>
          AspectRatio(aspectRatio: controller.playerAspectRatio.value, child: VideoPlayer(controller.player.value!)));
    } else if (controller.playerState.value == PlayState.error) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() => Text(controller.currentIPTV.value.name, style: const TextStyle(color: Colors.white, fontSize: 40))),
          const Text('直播加载失败', style: TextStyle(color: Colors.red, fontSize: 40)),
        ],
      );
    } else {
      // child = Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Obx(() => Text(controller.currentIPTV.value.name, style: const TextStyle(color: Colors.white, fontSize: 40))),
      //     const Text('直播加载中...', style: TextStyle(color: Colors.white, fontSize: 40)),
      //   ],
      // );
    }

    return Center(child: child);
  }

  Widget _buildIPTVIdxInput() {
    return Positioned(
      top: 20.h,
      right: 20.w,
      child: Row(
        children: [
          Obx(
            () => Text(
              controller.iptvChannelInput.value,
              style: TextStyle(color: Colors.white, fontSize: 90.sp, height: 1),
            ),
          ),
        ],
      ),
    );
  }

  void _showPanel() async {
    controller.selectedIPTV.value = controller.currentIPTV.value;

    StreamSubscription<IPTV>? selectedIPTVSubscription;

    await Navigator.of(Get.context!).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.groupScrollController.jumpTo(clampDouble(
              controller.currentIPTV.value.group.idx * 170.h,
              controller.groupScrollController.position.minScrollExtent,
              controller.groupScrollController.position.maxScrollExtent,
            ));
            controller.iptvScrollController.jumpTo(clampDouble(
              (controller.currentIPTV.value.idx - 1) * 300.w,
              controller.iptvScrollController.position.minScrollExtent,
              controller.iptvScrollController.position.maxScrollExtent,
            ));

            selectedIPTVSubscription = controller.selectedIPTV.listen((iptv) async {
              await controller.groupScrollController.animateTo(
                clampDouble(
                  iptv.group.idx * 170.h,
                  controller.groupScrollController.position.minScrollExtent,
                  controller.groupScrollController.position.maxScrollExtent,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              await controller.iptvScrollController.animateTo(
                clampDouble(
                  (iptv.idx - 1) * 300.0.w,
                  controller.iptvScrollController.position.minScrollExtent,
                  controller.iptvScrollController.position.maxScrollExtent,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          });

          return ListenGesture(
            onTap: () => Navigator.pop(context),
            child: Scaffold(backgroundColor: Colors.white.withOpacity(0), body: _buildPanel()),
          );
        },
      ),
    );

    selectedIPTVSubscription?.cancel();
  }

  Widget _buildPanel({bool showIPTVGroupList = true}) {
    return ListenKeyboard(
      onKeyArrowUp: () => controller.selectPrevGroupIPTV(),
      onKeyArrowDown: () => controller.selectNextGroupIPTV(),
      onKeyArrowLeft: () => controller.selectPrevIPTV(),
      onKeyArrowRight: () => controller.selectNextIPTV(),
      onKeySelect: () {
        Navigator.pop(Get.context!);
        controller.playIPTV(controller.selectedIPTV.value);
      },
      child: Stack(
        children: [
          Positioned(
            top: 20.h,
            right: 20.w,
            child: Row(
              children: [
                _buildPanelIPTVNo(),
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 0, 12, 0).r,
                  child: SizedBox(
                    height: 50.w,
                    child: VerticalDivider(
                      thickness: 2.w,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildPanelTime(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 20, left: 40).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPanelIPTVInfo(),
                  SizedBox(height: 40.h),
                  _buildPanelPlayerStatus(),
                  SizedBox(height: 40.h),
                  showIPTVGroupList ? _buildPanelIPTVGroupList() : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelTime() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(
          () => Text(
            DateFormat('MM月dd日   E', 'zh-CN').format(controller.currentTime.value),
            style: TextStyle(color: Colors.white, fontSize: 20.sp),
          ),
        ),
        Obx(
          () => Text(
            DateFormat('HH:mm:ss').format(controller.currentTime.value),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildPanelIPTVNo() {
    return Obx(
      () => Text(
        controller.currentIPTV.value.channel.toString().padLeft(2, '0'),
        style: TextStyle(color: Colors.white, fontSize: 90.sp, height: 1),
      ),
    );
  }

  Widget _buildPanelIPTVInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            controller.currentIPTV.value.name,
            style: TextStyle(color: Colors.white, fontSize: 80.sp, fontWeight: FontWeight.bold, height: 1),
          ),
        ),
        // Text(
        //   '正在播放：无法获取',
        //   style: TextStyle(color: Colors.white70, fontSize: 30.sp),
        // ),
      ],
    );
  }

  Widget _buildPanelPlayerStatus() {
    return Row(
      children: [
        Row(
          children: [
            FaIcon(FontAwesomeIcons.tv, color: Colors.white, size: 26.sp),
            SizedBox(width: 8.w),
            Obx(
              () => Text(
                '${controller.playerResolution.value.width.toInt()}×${controller.playerResolution.value.height.toInt()}',
                style: TextStyle(color: Colors.white, fontSize: 30.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPanelIPTVGroupList() {
    return SizedBox(
      height: 250.h,
      child: Obx(
        () => ListView.separated(
          padding: EdgeInsets.only(bottom: 20.sp),
          controller: controller.groupScrollController,
          itemBuilder: (context, groupIdx) {
            final group = controller.iptvGroupList[groupIdx];
            return SizedBox(
              height: 150.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(color: Colors.white, fontSize: 30.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14.h),
                  _buildPanelIPTVList(group)
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 20.h),
          itemCount: controller.iptvGroupList.length,
        ),
      ),
    );
  }

  Widget _buildPanelIPTVList(IPTVGroup group) {
    return SizedBox(
      height: 100.h,
      child: Obx(
        () => ListView.separated(
          controller:
              controller.selectedIPTV.value.group == group ? controller.iptvScrollController : ScrollController(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, iptvIdx) {
            final iptv = group.list[iptvIdx];

            return GestureDetector(
              onTap: () {
                controller.playIPTV(iptv);
              },
              behavior: HitTestBehavior.opaque,
              child: Obx(
                () => Container(
                  width: 280.w,
                  decoration: BoxDecoration(
                    color: controller.selectedIPTV.value == iptv ? Colors.white : Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20).r,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 4.h,
                        right: 4.w,
                        child: Text(
                          '#${iptv.channel.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: controller.selectedIPTV.value == iptv ? Colors.black : Colors.white70,
                            fontSize: 28.sp,
                            height: 1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10).r,
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            iptv.name.replaceFirst(' ', '\n'),
                            style: TextStyle(
                              color: controller.selectedIPTV.value == iptv ? Colors.black : Colors.white,
                              fontSize: 36.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, idx) => SizedBox(width: 20.w),
          itemCount: group.list.length,
        ),
      ),
    );
  }
}
