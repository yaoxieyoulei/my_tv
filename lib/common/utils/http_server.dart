import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:my_tv/common/index.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

final _logger = LoggerUtil.create(['http_server']);

class HttpServerUtil {
  HttpServerUtil._();

  static var _isInitialized = false;

  static String serverUrl = 'http://0.0.0.0:${Constants.httpServerPort}';

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    var app = Router();

    app.get('/', (request) async {
      return shelf.Response.ok(
        await rootBundle.loadString('assets/web/index.html'),
        headers: {'content-type': 'text/html'},
      );
    });

    app.get('/api/settings', (request) async {
      return shelf.Response.ok(
        json.encode({
          "appBootLaunch": AppSettings.bootLaunch,
          "iptvChannelChangeFlip": IptvSettings.channelChangeFlip,
          "iptvSourceSimplify": IptvSettings.iptvSourceSimplify,
          "iptvSourceCacheTime": IptvSettings.iptvSourceCacheTime,
          "iptvSourceCacheKeepTime": IptvSettings.iptvSourceCacheKeepTime,
          "iptvCustomSource": IptvSettings.customIptvSource,
          "epgEnable": IptvSettings.epgEnable,
          "epgXmlCacheTime": IptvSettings.epgXmlCacheTime,
          "epgCacheHash": IptvSettings.epgCacheHash,
          "epgCustomXml": IptvSettings.customEpgXml,
          "epgRefreshTimeThreshold": IptvSettings.epgRefreshTimeThreshold,
        }),
        headers: {'content-type': 'application/json'},
      );
    });

    app.post('/api/settings', (request) async {
      var body = await request.readAsString();
      var data = jsonDecode(body);

      AppSettings.bootLaunch = data['appBootLaunch'];
      IptvSettings.channelChangeFlip = data['iptvChannelChangeFlip'];
      IptvSettings.iptvSourceSimplify = data['iptvSourceSimplify'];
      IptvSettings.iptvSourceCacheTime = data['iptvSourceCacheTime'];
      IptvSettings.iptvSourceCacheKeepTime = data['iptvSourceCacheKeepTime'];
      IptvSettings.customIptvSource = data['iptvCustomSource'];
      IptvSettings.epgEnable = data['epgEnable'];
      IptvSettings.epgXmlCacheTime = data['epgXmlCacheTime'];
      IptvSettings.epgCacheHash = data['epgCacheHash'];
      IptvSettings.customEpgXml = data['epgCustomXml'];
      IptvSettings.epgRefreshTimeThreshold = data['epgRefreshTimeThreshold'];

      return shelf.Response.ok('success');
    });

    var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(app.call);

    var server = await io.serve(handler, InternetAddress.anyIPv4, Constants.httpServerPort);

    _isInitialized = true;
    serverUrl = 'http://${await _getLocalIPV4()}:${server.port}';

    _logger.debug('启动 $serverUrl');
  }

  static Future<String> _getLocalIPV4() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          if (addr.address.startsWith('192')) {
            return addr.address;
          }
        }
      }
    }

    return '0.0.0.0';
  }
}
