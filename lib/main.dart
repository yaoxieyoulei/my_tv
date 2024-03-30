import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_tv/common/index.dart';
import 'package:my_tv/pages/index.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  // 必须
  WidgetsFlutterBinding.ensureInitialized();

  // 强制横屏
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  // 小白条、导航栏沉浸
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  // 保持屏幕常亮
  Wakelock.enable();

  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 动态颜色
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        title: '我的电视',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
        ),
        localizationsDelegates: const [...GlobalMaterialLocalizations.delegates, GlobalWidgetsLocalizations.delegate],
        supportedLocales: const [Locale("zh", "CH"), Locale("en", "US")],
        home: const DoubleBackExit(child: LivePage()),
      ),
    );
  }
}
