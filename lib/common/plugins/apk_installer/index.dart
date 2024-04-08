import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ApkInstaller {
  static const platform = MethodChannel('my_tv.yogiczy.top/apkInstaller');

  static Future<void> installApk(String filePath) async {
    try {
      await platform.invokeMethod('installApk', {'filePath': filePath});
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to install APK: ${e.message}');
      }
    }
  }
}
