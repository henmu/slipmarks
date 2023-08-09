package com.slipmarks.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "web_content_share"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent: Intent? = intent
        val action: String? = intent?.action
        val type: String? = intent?.type

        
    Log.d("MainActivity", "onCreate: action=$action, type=$type")

        if (Intent.ACTION_SEND == action && "text/plain" == type) {
            if (intent.getStringExtra(Intent.EXTRA_TEXT) != null) {
                val sharedContent = intent.getStringExtra(Intent.EXTRA_TEXT)!!
                // Handle shared content here if needed
            }
        }
    }

    override fun onResume() {
        super.onResume()
        val intent = intent
        val action = intent?.action
        val type = intent?.type

        
    Log.d("MainActivity", "onResume: action=$action, type=$type")

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
                flutterEngine!!.dartExecutor.binaryMessenger,
                CHANNEL
            )
            methodChannel.invokeMethod("handleSharedContent", sharedText)
        }
    }

}
