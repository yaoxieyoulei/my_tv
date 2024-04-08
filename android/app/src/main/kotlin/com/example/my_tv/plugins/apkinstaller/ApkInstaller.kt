package com.example.my_tv.plugins.apkinstaller

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class ApkInstaller : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "my_tv.yogiczy.top/apkInstaller")
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "installApk") {
            val filePath = call.argument<String>("filePath")
            installApk(filePath!!)
            result.success(null)
        } else {
            result.notImplemented()
        }
    }

    @SuppressLint("SetWorldReadable")
    private fun installApk(filePath: String) {
        val file = File(filePath)
        if (file.exists()) {
            val cacheDir = applicationContext.cacheDir
            val cachedApkFile = File(cacheDir, file.name).apply {
                writeBytes(file.readBytes())
                setReadable(true, false)
            }

            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                FileProvider.getUriForFile(applicationContext, applicationContext.packageName + ".fileprovider", cachedApkFile)
            } else {
                Uri.fromFile(cachedApkFile)
            }

            val installIntent = Intent(Intent.ACTION_VIEW).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION
                setDataAndType(uri, "application/vnd.android.package-archive")
            }

            applicationContext.startActivity(installIntent)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
