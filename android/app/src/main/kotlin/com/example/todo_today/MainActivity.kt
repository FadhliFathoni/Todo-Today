package com.example.todo_today

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import id.flutter.flutter_background_service.FlutterBackgroundServicePlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register the plugin
        flutterEngine.plugins.add(FlutterBackgroundServicePlugin())
    }
}
