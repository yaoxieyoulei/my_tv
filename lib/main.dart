import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/enums/debug_setting.dart';
import 'package:my_tv/common/index.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_tv/pages/index.dart';
import 'package:oktoast/oktoast.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
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
  WakelockPlus.enable();

  // 初始化
  await PrefsUtil.init();
  LoggerUtil.init();
  RequestUtil.init();

  // 注册全局Store
  GetIt.I.registerSingleton(PlayerStore());
  GetIt.I.registerSingleton(IptvStore());
  GetIt.I.registerSingleton(UpdateStore());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme.dark(background: Colors.black);

    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      child: RestartWidget(
        child: MaterialApp(
          title: '我的电视',
          theme: ThemeData(
            colorScheme: colorScheme,
          ),
          localizationsDelegates: const [...GlobalMaterialLocalizations.delegates, GlobalWidgetsLocalizations.delegate],
          supportedLocales: const [Locale("zh", "CH"), Locale("en", "US")],
          home: ShowFPS(
            visible: DebugSettings.showFPS,
            child: const DoubleBackExit(
              child: IptvPage(),
            ),
          ),
          builder: (BuildContext context, Widget? widget) {
            return OKToast(
              position: const ToastPosition(align: Alignment.topCenter, offset: 0),
              textPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              dismissOtherOnShow: true,
              child: widget!,
            );
          },
        ),
      ),
    );
  }
}
