package com.slipmarks.app
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle

import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "web_content_share"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Intent.ACTION_SEND == intent.action && intent.type != null) {
            if ("text/plain" == intent.type) {
                intent.getStringExtra(Intent.EXTRA_TEXT)?.let { sharedText ->
                    handleSharedText(sharedText)
                }
            }
        }
    }   

    override fun onResume() {
        super.onResume()
        
        // If sharedText is not null, handle it
        val sharedText = intent?.getStringExtra(Intent.EXTRA_TEXT)
                
        Log.d("MainActivity", "Intent contents: ${intent.toString()}")
        Log.d("MainActivity", "Intent action: ${intent.action}")
        Log.d("MainActivity", "Intent type: ${intent.type}")
        Log.d("MainActivity", "Intent extras: ${intent.extras}")
        Log.d("MainActivity", "onResume: sharedText=$sharedText")
        
        if (sharedText != null) {
            handleSharedText(sharedText)
        }
    }

    private fun handleSharedText(sharedText: String) {
        val sharedTitle = intent?.getStringExtra(Intent.EXTRA_SUBJECT) // Chrome at least provides subject as title
        
        val methodChannel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
        val arguments = if (sharedTitle != null) {
            mapOf("url" to sharedText, "title" to sharedTitle)
        } else {
            mapOf("url" to sharedText) // Fallback to just using the URL
        }
        methodChannel.invokeMethod("handleSharedContent", arguments)
    }
}