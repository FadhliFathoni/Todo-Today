import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wrapper tipis di atas package `speech_to_text` agar UI lebih mudah dipakai.
///
/// Semua proses STT berjalan di engine bawaan device (Android `SpeechRecognizer`,
/// iOS `Speech` framework). Tidak ada API eksternal.
///
/// **Singleton `SpeechToText`**: callback [initialize] hanya didaftarkan sekali.
/// Pakai [_session] supaya error/status selalu di-forward ke layar yang sedang aktif.
class VoiceInputService {
  VoiceInputService();

  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;

  /// Set true dari [dispose] — berhenti meneruskan error/status ke UI.
  bool _released = false;

  void Function(String status)? _userOnStatus;
  void Function(String error)? _userOnError;

  /// Instance yang sedang memiliki layar voice — update tiap [init].
  static VoiceInputService? _session;

  bool get isAvailable => _initialized;
  bool get isListening => _stt.isListening;

  /// Panggil dari `State.dispose`.
  void dispose() {
    _released = true;
    if (_session == this) {
      _session = null;
    }
    if (_stt.isListening) {
      unawaited(_stt.cancel());
    }
  }

  /// Satu closure yang didaftarkan ke [SpeechToText.initialize] (hanya efektif pada init pertama).
  static void _forwardError(SpeechRecognitionError e) {
    final s = _session;
    if (s == null || s._released) return;
    s._userOnError?.call(e.errorMsg);
  }

  static void _forwardStatus(String status) {
    final s = _session;
    if (s == null || s._released) return;
    s._userOnStatus?.call(status);
  }

  /// Inisialisasi engine. Wajib dipanggil sebelum `start()`.
  /// Mengembalikan true bila device punya STT engine yang aktif.
  Future<bool> init({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    _released = false;
    _session = this;
    _userOnStatus = onStatus;
    _userOnError = onError;

    if (_initialized) {
      return _initialized;
    }

    // speech_to_text tidak menyediakan implementasi Linux (plugin tidak ada di registrant).
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      if (!_released) {
        onError?.call(
          'Pengenalan suara belum didukung di Linux. Gunakan Android, iOS, Windows, macOS, atau Web.',
        );
      }
      return false;
    }

    try {
      _initialized = await _stt.initialize(
        onStatus: _forwardStatus,
        onError: _forwardError,
        debugLogging: false,
      );
    } on MissingPluginException catch (e, st) {
      debugPrint('VoiceInputService.init: MissingPluginException $e\n$st');
      _initialized = false;
      if (!_released) {
        onError?.call(
          'Plugin pengenalan suara tidak aktif. Setelah menambah dependency, lakukan stop app lalu `flutter clean` dan build ulang (bukan hot reload). '
          'Di Windows pastikan `speech_to_text_windows` terdaftar; di Linux fitur ini tidak tersedia.',
        );
      }
      return false;
    }
    return _initialized;
  }

  /// Mulai listening. `onResult` dipanggil tiap kali ada partial / final result.
  /// [listenFor] / [pauseFor] dibuat sangat panjang supaya tidak auto-stop;
  /// hentikan dengan [stop()] dari UI (mis. tap mic kedua).
  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    String localeId = 'id_ID',
    Duration listenFor = const Duration(hours: 24),
    Duration pauseFor = const Duration(hours: 24),
  }) async {
    if (!_initialized) {
      throw StateError('VoiceInputService.init() harus dipanggil dulu.');
    }
    await _stt.listen(
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: pauseFor,
      onResult: (SpeechRecognitionResult r) {
        if (_released) return;
        onResult(r.recognizedWords, r.finalResult);
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> stop() async {
    if (_stt.isListening) await _stt.stop();
  }

  Future<void> cancel() async {
    if (_stt.isListening) await _stt.cancel();
  }
}
