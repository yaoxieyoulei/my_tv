import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局
class Global {
  static late final Logger logger;

  static late final Dio dio;

  static late final SharedPreferences prefs;

  static Future<void> init() async {
    logger = Logger();

    dio = Dio();
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: logger.w,
      retries: 10,
    ));

    prefs = await SharedPreferences.getInstance();
  }
}
