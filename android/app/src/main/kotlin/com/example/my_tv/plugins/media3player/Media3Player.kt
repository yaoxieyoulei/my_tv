package com.example.my_tv.plugins.media3player

import android.content.Context
import android.net.Uri
import android.view.Surface
import androidx.annotation.OptIn
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.VideoSize
import androidx.media3.common.util.UnstableApi
import androidx.media3.common.util.Util
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.dash.DashMediaSource
import androidx.media3.exoplayer.dash.DefaultDashChunkSource
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.exoplayer.smoothstreaming.DefaultSsChunkSource
import androidx.media3.exoplayer.smoothstreaming.SsMediaSource
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import io.flutter.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.view.TextureRegistry


@OptIn(UnstableApi::class)
class Media3Player(
    context: Context,
    eventChannel: EventChannel,
    private val textureEntry: TextureRegistry.SurfaceTextureEntry,
) : Player.Listener {
    private var player: ExoPlayer
    private var surface: Surface
    private var dataSourceFactory: DataSource.Factory
    private var eventSink: QueuingEventSink

    init {
        // 渲染
        val renderersFactory = DefaultRenderersFactory(context)

        player = ExoPlayer.Builder(context).setRenderersFactory(renderersFactory).build()

        // http请求
        val httpDataSourceFactory = DefaultHttpDataSource.Factory().apply {
            setUserAgent("ExoPlayer")
            setConnectTimeoutMs(5_000)
            setKeepPostFor302Redirects(true)
            setAllowCrossProtocolRedirects(true)
        }

        // 数据源
        dataSourceFactory = DefaultDataSource.Factory(context, httpDataSourceFactory)

        surface = Surface(textureEntry.surfaceTexture())
        player.setVideoSurface(this.surface)

        // 消息事件
        eventSink = QueuingEventSink()
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink.setDelegate(events)
            }

            override fun onCancel(arguments: Any?) {
                eventSink.setDelegate(null)
            }

        })

        player.addListener(this)
    }

    // 监听播放状态改变
    override fun onPlaybackStateChanged(playbackState: Int) {
        when (playbackState) {
            // 缓冲中
            Player.STATE_BUFFERING -> {
                Log.d(TAG, "onPlaybackStateChanged: STATE_BUFFERING")
                eventSink.success(mapOf("event" to "stateBuffering", "isBuffering" to true))
            }

            // 播放结束
            Player.STATE_ENDED -> {
                Log.d(TAG, "onPlaybackStateChanged: STATE_ENDED")
                eventSink.success(mapOf("event" to "stateEnded"))
            }

            // 空闲等待
            Player.STATE_IDLE -> {
                Log.d(TAG, "onPlaybackStateChanged: STATE_IDLE")
                eventSink.success(mapOf("event" to "stateIdle"))
            }

            // 准备完成，可以播放
            Player.STATE_READY -> {
                Log.d(TAG, "onPlaybackStateChanged: STATE_READY")
                eventSink.success(mapOf("event" to "stateReady"))
            }
        }

        if (playbackState != Player.STATE_BUFFERING) {
            Log.d(TAG, "onPlaybackStateChanged: STATE_NO_BUFFERING")
            eventSink.success(mapOf("event" to "state_buffering", "isBuffering" to false))
        }
    }

    // 监听播放失败
    override fun onPlayerError(error: PlaybackException) {
        Log.e(TAG, "onPlayerError: $error")

        if (error.errorCode == PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW) {
            player.seekToDefaultPosition()
            player.prepare()
        } else {
            eventSink.error("VideoError", error.message ?: "Unknown Error", error)
        }
    }

    override fun onIsPlayingChanged(isPlaying: Boolean) {
        Log.d(TAG, "onIsPlayingChanged: $isPlaying")
        eventSink.success(mapOf("event" to "isPlayingChanged", "isPlaying" to isPlaying))
    }

    override fun onVideoSizeChanged(videoSize: VideoSize) {
        Log.d(TAG, "onVideoSizeChanged: ${videoSize.width}x${videoSize.height}")
        eventSink.success(
            mapOf(
                "event" to "videoSizeChanged",
                "width" to videoSize.width,
                "height" to videoSize.height,
            )
        )
    }

    fun prepare(dataSource: String, contentType: Int?, playWhenReady: Boolean?) {
        val uri = Uri.parse(dataSource)
        val mediaSource = getMediaSource(uri, dataSourceFactory, contentType)

        player.setMediaSource(mediaSource)
        player.prepare()
        player.playWhenReady = playWhenReady ?: false
    }

    fun play() {
        player.play()
    }

    fun pause() {
        player.pause()
    }

    fun stop() {
        player.stop()
    }

    fun dispose() {
        player.removeListener(this)
        player.stop()
        player.release()
        textureEntry.release()
        surface.release()
    }

    private fun getMediaSource(
        uri: Uri, dataSourceFactory: DataSource.Factory, contentType: Int?
    ): MediaSource {
        val mediaItem = MediaItem.fromUri(uri)
        when (val type = contentType ?: Util.inferContentType(uri)) {
            C.CONTENT_TYPE_HLS -> {
                return HlsMediaSource.Factory(dataSourceFactory).createMediaSource(mediaItem)
            }

            C.CONTENT_TYPE_DASH -> {
                return DashMediaSource.Factory(
                    DefaultDashChunkSource.Factory(dataSourceFactory), dataSourceFactory
                ).createMediaSource(mediaItem)
            }

            C.CONTENT_TYPE_SS -> {
                return SsMediaSource.Factory(
                    DefaultSsChunkSource.Factory(dataSourceFactory), dataSourceFactory
                ).createMediaSource(mediaItem)
            }

            C.CONTENT_TYPE_OTHER -> {
                return ProgressiveMediaSource.Factory(dataSourceFactory)
                    .createMediaSource(mediaItem)
            }

            else -> {
                throw IllegalStateException("Unsupported type: $type")
            }
        }
    }

    companion object {
        const val TAG = "Media3Player"
    }
}