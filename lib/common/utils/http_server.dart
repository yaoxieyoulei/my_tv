import 'dart:io';

import 'package:my_tv/common/index.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

final _logger = LoggerUtil.create(['http_server']);

class HttpServerUtil {
  HttpServerUtil._();

  static var _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    var app = Router();
    app.get('/', (request) {
      return shelf.Response.ok('Hello, world!');
    });

    app.get('/api/iptv_setting/customIptvSource', (request) async {
      var m3u = request.url.queryParameters['m3u'] as String;

      _logger.debug('设置自定义m3u: $m3u');
      IptvSettings.customIptvSource = m3u;
      IptvSettings.iptvSourceSimplify = false;
      IptvSettings.iptvSourceCacheTime = 0;
      IptvSettings.epgCacheHash = 0;

      return shelf.Response.ok('success');
    });

    var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(app.call);

    var server = await io.serve(handler, InternetAddress.anyIPv4, Constants.httpServerPort);
    _isInitialized = true;
    _logger.debug('启动 http://${server.address.host}:${server.port}');
  }
}
