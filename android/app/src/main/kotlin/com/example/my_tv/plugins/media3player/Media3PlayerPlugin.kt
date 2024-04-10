package com.example.my_tv.plugins.media3player

import android.content.Context
import android.util.LongSparseArray
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.view.TextureRegistry

class Media3PlayerPlugin : FlutterPlugin, AndroidMedia3PlayerApi {
    private lateinit var flutterState: FlutterState

    private val videoPlayers = LongSparseArray<Media3Player>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterState = FlutterState(
            binding.applicationContext,
            binding.binaryMessenger,
            binding.textureRegistry,
        )
        flutterState.startListening(this, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterState.stopListening(binding.binaryMessenger)
        disposeAllPlayer()
    }

    private fun disposeAllPlayer() {
        for (i in 0..<videoPlayers.size()) {
            videoPlayers.valueAt(i).dispose()
        }
        videoPlayers.clear()
    }

    override fun initialize() {
        Log.d(TAG, "initialize")
        disposeAllPlayer()
    }

    override fun create(): TextureMessage {
        Log.d(TAG, "create")

        val textureEntry = flutterState.textureRegistry.createSurfaceTexture()
        val eventChannel = EventChannel(
            flutterState.binaryMessenger,
            "my_tv.yogiczy.top/media3Player/media3Events" + textureEntry.id()
        )
        val player = Media3Player(flutterState.applicationContext, eventChannel, textureEntry)
        videoPlayers.put(textureEntry.id(), player)

        return TextureMessage(textureEntry.id())
    }

    override fun prepare(msg: PrepareMessage) {
        Log.d(TAG, "setDataSource: $msg")

        val player = videoPlayers.get(msg.textureId)
        player.prepare(msg.dataSource, msg.contentType?.toInt(), msg.playWhenReady)
    }

    override fun play(msg: PlayMessage) {
        Log.d(TAG, "play: $msg")

        val player = videoPlayers.get(msg.textureId)
        player.play()
    }

    override fun pause(msg: PauseMessage) {
        Log.d(TAG, "pause: $msg")

        val player = videoPlayers.get(msg.textureId)
        player.pause()
    }

    override fun stop(msg: StopMessage) {
        Log.d(TAG, "stop: $msg")

        val player = videoPlayers.get(msg.textureId)
        player.stop()
    }

    override fun dispose(msg: DisposeMessage) {
        Log.d(TAG, "dispose: $msg")

        val player = videoPlayers.get(msg.textureId)
        player.dispose()
        videoPlayers.remove(msg.textureId)
    }

    companion object {
        const val TAG = "Media3PlayerPlugin"

        class FlutterState(
            val applicationContext: Context,
            val binaryMessenger: BinaryMessenger,
            val textureRegistry: TextureRegistry,
        ) {
            fun startListening(methodCallHandle: Media3PlayerPlugin, messenger: BinaryMessenger) {
                AndroidMedia3PlayerApi.setUp(messenger, methodCallHandle)
            }

            fun stopListening(messenger: BinaryMessenger) {
                AndroidMedia3PlayerApi.setUp(messenger, null)
            }
        }
    }
}