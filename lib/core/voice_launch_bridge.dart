import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/core/app_navigator.dart';
import 'package:todo_today/views/Money/voice/pages/voice_input_page.dart';

/// Menghubungkan intent dari App Widget Android (`launch_action`) ke [VoiceInputPage].
class VoiceLaunchBridge {
  VoiceLaunchBridge._();

  static const MethodChannel _channel =
      MethodChannel('com.example.todo_today/launch');

  /// Daftar sekali di awal aplikasi untuk tap widget saat app sudah berjalan.
  static void registerResumeListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onResumeLaunchAction') {
        final action = call.arguments as String?;
        if (action == 'open_voice_finance') {
          await _openVoiceFromWidget();
        }
      }
    });
  }

  static Future<void> _openVoiceFromWidget() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    if (user == null || user.isEmpty) return;
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    nav.push(
      MaterialPageRoute<void>(
        builder: (context) => VoiceInputPage(user: user),
      ),
    );
  }

  /// Baca intent cold start (sekali) — panggil dari [MainPage] saat user sudah login.
  static Future<void> consumeInitialLaunchIfNeeded(
    BuildContext context,
    String user,
  ) async {
    try {
      final action = await _channel.invokeMethod<String>('getInitialLaunchAction');
      if (!context.mounted) return;
      if (action == 'open_voice_finance') {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => VoiceInputPage(user: user),
          ),
        );
      }
    } on PlatformException catch (_) {
      // Channel belum siap / bukan Android — abaikan.
    }
  }
}
