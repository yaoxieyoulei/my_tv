import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:logger/logger.dart';

/// 全局
class Global {
  static final logger = Logger();

  static final dio = () {
    final dio = Dio();

    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: logger.w,
      retries: 10,
    ));

    return dio;
  }();
}
