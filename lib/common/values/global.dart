import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// 全局
class Global {
  static late final Talker logger;

  static late final Dio dio;

  static late final SharedPreferences prefs;

  static Future<void> init() async {
    logger = TalkerFlutter.init(settings: TalkerSettings(useHistory: false));

    dio = Dio();
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: logger.warning,
      retries: 10,
    ));

    prefs = await SharedPreferences.getInstance();
  }
}
