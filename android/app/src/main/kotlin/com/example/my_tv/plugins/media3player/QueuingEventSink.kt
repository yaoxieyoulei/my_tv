package com.example.my_tv.plugins.media3player

import io.flutter.plugin.common.EventChannel

/**
 * And implementation of [EventChannel.EventSink] which can wrap an underlying sink.
 *
 *
 * It delivers messages immediately when downstream is available, but it queues messages before
 * the delegate event sink is set with setDelegate.
 *
 *
 * This class is not thread-safe. All calls must be done on the same thread or synchronized
 * externally.
 */
class QueuingEventSink : EventChannel.EventSink {
    private var delegate: EventChannel.EventSink? = null
    private val eventQueue = ArrayList<Any>()
    private var done = false

    fun setDelegate(delegate: EventChannel.EventSink?) {
        this.delegate = delegate
        maybeFlush()
    }

    override fun endOfStream() {
        enqueue(EndOfStreamEvent())
        maybeFlush()
        done = true
    }

    override fun error(code: String, message: String, details: Any) {
        enqueue(ErrorEvent(code, message, details))
        maybeFlush()
    }

    override fun success(event: Any) {
        enqueue(event)
        maybeFlush()
    }

    private fun enqueue(event: Any) {
        if (done) {
            return
        }
        eventQueue.add(event)
    }

    private fun maybeFlush() {
        if (delegate == null) {
            return
        }
        for (event in eventQueue) {
            when (event) {
                is EndOfStreamEvent -> {
                    delegate!!.endOfStream()
                }

                is ErrorEvent -> {
                    delegate!!.error(event.code, event.message, event.details)
                }

                else -> {
                    delegate!!.success(event)
                }
            }
        }
        eventQueue.clear()
    }

    internal class EndOfStreamEvent

    private class ErrorEvent(
        val code: String, val message: String, val details: Any
    )
}
