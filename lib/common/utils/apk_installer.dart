import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ApkInstaller {
  static const platform = MethodChannel('apk_installer');

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
