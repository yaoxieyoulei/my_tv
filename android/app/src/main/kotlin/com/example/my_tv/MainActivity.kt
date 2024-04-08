package com.example.my_tv

import android.os.Bundle
import com.example.my_tv.plugins.apkinstaller.ApkInstaller
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        UnsafeTrustManager.enableUnsafeTrustManager()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        flutterEngine.plugins.add(ApkInstaller())
    }
}