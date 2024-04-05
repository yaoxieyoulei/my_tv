import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:my_tv/common/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

/// 网络请求工具
class RequestUtil {
  static late final Logger _logger;

  static void init() {
    HttpOverridesUtil.init();
    _logger = LoggerUtil.create(['网络请求']);
  }

  static RetryClient _client() {
    return RetryClient(
      http.Client(),
      retries: 10,
      delay: (retryCount) => Duration(seconds: retryCount.clamp(3, 5)),
      when: (resp) => resp.statusCode != 200,
      whenError: (_, __) => true,
      onRetry: (req, resp, retryCount) {
        _logger.warning('${req.url} 请求失败，正在重试: $retryCount');
      },
    );
  }

  static Future<String> get(String url) async {
    final client = _client();
    try {
      final resp = await client.get(Uri.parse(url));
      return utf8.decode(resp.bodyBytes);
    } finally {
      client.close();
    }
  }

  static Future<String> downloadTemporary(
    String url, {
    Function(double)? onProgress,
  }) async {
    final thr = Throttle(duration: const Duration(seconds: 1));

    final client = http.Client();
    final response = await client.send(http.Request('GET', Uri.parse(url)));

    if (response.statusCode != 200) {
      throw Exception('请求失败: ${response.statusCode}: ${response.reasonPhrase}');
    }

    final file = await File('${(await getTemporaryDirectory()).path}/${url.split('/').last}').create();

    final totalBytes = response.contentLength ?? 1;
    var downloadedBytes = 0;

    await file.openWrite().addStream(response.stream.transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        downloadedBytes += data.length;
        thr.throttle(() => onProgress?.call(downloadedBytes / totalBytes * 100));
        sink.add(data);
      },
    )));

    client.close();

    return file.path;
  }
}
