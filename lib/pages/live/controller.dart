import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_tv/common/index.dart';
import 'package:video_player/video_player.dart';

enum PlayState {
  none,
  waiting,
  playing,
  error,
}

class LiveController extends GetxController {
  LiveController();

  /// 当前时间
  var currentTime = DateTime.now().obs;

  /// 播放器
  final player = Rxn<VideoPlayerController>();

  /// 播放器宽高比
  final playerAspectRatio = 1.0.obs;

  /// 播放器分辨率
  final playerResolution = Rx<Size>(Size.zero);

  /// 播放状态
  final playerState = Rx<PlayState>(PlayState.none);

  /// 直播源分组列表
  var iptvGroupList = <IPTVGroup>[].obs;

  /// 直播源列表
  var iptvList = <IPTV>[].obs;

  /// 当前直播源
  var currentIPTV = IPTV(idx: 0, channel: 0, group: IPTVGroup(idx: 0, name: '', list: []), name: '', url: '').obs;

  /// 当前直播源序号
  var currentIPTVIdx = 0.val('currentIPTVIdx');

  /// 选中直播源
  var selectedIPTV = IPTV(idx: 0, channel: 0, group: IPTVGroup(idx: 0, name: '', list: []), name: '', url: '').obs;

  /// 直播源分组滚动控制器
  final groupScrollController = ScrollController();

  /// 直播源滚动控制器
  final iptvScrollController = ScrollController();

  /// 直播源频道号输入
  var iptvChannelInput = ''.obs;

  /// 输入直播源频道号结束定时
  Timer? inputIPTVChannelTimer;

  /// 临时展示信息面板
  var tempPanelVisible = false.obs;

  /// 临时展示信息面板定时器
  Timer? tempPanelVisibleTimer;

  /// 播放直播源
  void playIPTV(IPTV iptv) async {
    if (currentIPTV.value == iptv) return;

    try {
      Global.logger.d("播放直播源: $iptv");

      currentIPTV.value = iptv;
      selectedIPTV.value = iptv;
      playerState.value = PlayState.waiting;

      tempPanelVisibleTimer?.cancel();
      tempPanelVisible.value = true;

      await player.value?.pause();
      await player.value?.dispose();

      player.value = VideoPlayerController.networkUrl(Uri.parse(iptv.url));
      await player.value?.initialize();
      await player.value?.play();

      playerState.value = PlayState.playing;
      playerAspectRatio.value = player.value!.value.aspectRatio;
      playerResolution.value = player.value!.value.size;
    } catch (err) {
      Global.logger.e("播放失败 $err");

      playerState.value = PlayState.error;
    } finally {
      tempPanelVisibleTimer = Timer(const Duration(seconds: 1), () {
        tempPanelVisible.value = false;
      });
    }
  }

  /// 获取下一个直播源
  IPTV getNextIPTV() {
    final nextIdx = iptvList.indexOf(currentIPTV.value) + 1;
    return nextIdx >= iptvList.length ? iptvList.first : iptvList.elementAt(nextIdx);
  }

  /// 获取上一个直播源
  IPTV getPrevIPTV() {
    final prevIdx = iptvList.indexOf(currentIPTV.value) - 1;
    return prevIdx < 0 ? iptvList.last : iptvList.elementAt(prevIdx);
  }

  /// 播放下一个直播源
  void playNextIPTV() {
    playIPTV(getNextIPTV());
  }

  /// 播放上一个直播源
  void playPrevIPTV() {
    playIPTV(getPrevIPTV());
  }

  /// 输入直播源频道号
  void inputIPTVChannel(int digit) {
    iptvChannelInput.value += digit.toString();

    inputIPTVChannelTimer?.cancel();
    inputIPTVChannelTimer = Timer(Duration(seconds: 4 - iptvChannelInput.value.length), () {
      final channel = int.tryParse(iptvChannelInput.value) ?? 1;

      final iptv = iptvList.firstWhereOrNull((e) => e.channel == channel);

      if (iptv == null) {
        Fluttertoast.showToast(msg: '频道号无效', gravity: ToastGravity.TOP);
        iptvChannelInput.value = '';
        return;
      }

      playIPTV(iptv);

      iptvChannelInput.value = '';
    });
  }

  /// 选中下一个直播源
  void selectNextIPTV() {
    final idx = iptvList.indexOf(selectedIPTV.value);
    final nextIdx = idx + 1;

    if (nextIdx >= iptvList.length) return;
    selectedIPTV.value = iptvList.elementAt(nextIdx);
  }

  /// 选中上一个直播源
  void selectPrevIPTV() {
    final idx = iptvList.indexOf(selectedIPTV.value);
    final prevIdx = idx - 1;

    if (prevIdx < 0) return;
    selectedIPTV.value = iptvList.elementAt(prevIdx);
  }

  /// 选中下一个分组直播源
  void selectNextGroupIPTV() {
    final idx = iptvGroupList.indexOf(selectedIPTV.value.group);
    final nextIdx = idx + 1;

    if (nextIdx >= iptvGroupList.length) return;
    selectedIPTV.value = iptvGroupList.elementAt(nextIdx).list.first;
  }

  /// 选中上一个分组直播源
  void selectPrevGroupIPTV() {
    final idx = iptvGroupList.indexOf(selectedIPTV.value.group);
    final prevIdx = idx - 1;

    if (prevIdx < 0) return;
    selectedIPTV.value = iptvGroupList.elementAt(prevIdx).list.first;
  }

  _initData() async {
    update(["live"]);

    iptvGroupList.value = await IPTVUtil.parseFromM3u(await IPTVUtil.fetchM3u());
    iptvList.value = iptvGroupList.expand((e) => e.list).toList();

    playIPTV(iptvList.elementAtOrNull(currentIPTVIdx.val) ?? iptvList.firstOrNull ?? currentIPTV.value);

    currentIPTV.listen((iptv) {
      currentIPTVIdx.val = iptvList.indexOf(iptv);
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }
}
