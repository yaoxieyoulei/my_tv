import 'dart:io';

import 'package:my_tv/common/index.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class HttpServerUtil {
  static Future<void> init() async {
    var app = Router();
    app.get('/', (request) {
      return shelf.Response.ok('Hello, world!');
    });

    app.get('/api/iptv_settings/customIptvM3u', (request) async {
      var m3u = request.url.queryParameters['m3u'] as String;

      Global.logger.d('[服务端] 设置自定义m3u: $m3u');
      IptvSettings.customIptvM3u = m3u;
      IptvSettings.iptvType = IptvSettingIptvType.full;
      IptvSettings.iptvCacheTime = 0;
      IptvSettings.epgCacheHash = 0;

      return shelf.Response.ok('success');
    });

    var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(app.call);

    var server = await io.serve(handler, InternetAddress.anyIPv4, Constants.httpServerPort);

    Global.logger.d('[服务端] 启动 http://${server.address.host}:${server.port}');
  }
}
