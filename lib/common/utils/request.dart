import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:my_tv/common/index.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// 网络请求工具
class RequestUtil {
  static late final Dio _instance;

  RequestUtil._();

  /// 初始化
  static void init() {
    final logger = LoggerUtil.create(['网络请求']);

    _instance = Dio();

    _instance.interceptors.add(
      TalkerDioLogger(
        talker: LoggerUtil.logger,
        settings: const TalkerDioLoggerSettings(),
      ),
    );

    _instance.interceptors.add(RetryInterceptor(
      dio: _instance,
      logPrint: logger.warning,
      retries: 10,
    ));
  }

  static Future<T> get<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options}) async {
    final resp = await _instance.get<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    if (resp.statusCode != 200) {
      throw Exception('请求失败: ${resp.statusCode}: ${resp.statusMessage}');
    }

    return resp.data!;
  }
}
