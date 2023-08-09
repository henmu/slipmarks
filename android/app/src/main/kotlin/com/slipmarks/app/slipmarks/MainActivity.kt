package com.slipmarks.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "web_content_share"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent: Intent? = intent
        val action: String? = intent?.action
        val type: String? = intent?.type

        if (Intent.ACTION_SEND == action && type != null) {
            if ("text/plain" == type) {
                handleSharedText(intent)
            }
        }
    }

    private fun handleSharedText(intent: Intent) {
        val sharedText: String? = intent.getStringExtra(Intent.EXTRA_TEXT)
        if (sharedText != null) {
            val methodChannel = MethodChannel(
                flutterEngine!!.dartExecutor!!.binaryMessenger,
                CHANNEL
            )
            methodChannel.invokeMethod("handleSharedContent", sharedText)
        }
    }
}

