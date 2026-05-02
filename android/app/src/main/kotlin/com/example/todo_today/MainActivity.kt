package com.example.todo_today

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import id.flutter.flutter_background_service.FlutterBackgroundServicePlugin

class MainActivity : FlutterActivity() {

    companion object {
        private var pendingLaunchAction: String? = null
        private const val CHANNEL = "com.example.todo_today/launch"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(FlutterBackgroundServicePlugin())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialLaunchAction") {
                val action = pendingLaunchAction
                pendingLaunchAction = null
                result.success(action)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        captureLaunchAction(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureLaunchAction(intent)
        val action = intent.getStringExtra("launch_action") ?: return
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).invokeMethod("onResumeLaunchAction", action)
        }
    }

    private fun captureLaunchAction(intent: Intent?) {
        // null jika bukan dari widget — hapus intent lama agar tidak membuka suara dua kali.
        pendingLaunchAction = intent?.getStringExtra("launch_action")
    }
}
