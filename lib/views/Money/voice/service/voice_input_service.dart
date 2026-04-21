import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wrapper tipis di atas package `speech_to_text` agar UI lebih mudah dipakai.
///
/// Semua proses STT berjalan di engine bawaan device (Android `SpeechRecognizer`,
/// iOS `Speech` framework). Tidak ada API eksternal.
class VoiceInputService {
  VoiceInputService();

  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;

  bool get isAvailable => _initialized;
  bool get isListening => _stt.isListening;

  /// Inisialisasi engine. Wajib dipanggil sebelum `start()`.
  /// Mengembalikan true bila device punya STT engine yang aktif.
  Future<bool> init({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    if (_initialized) return true;
    _initialized = await _stt.initialize(
      onStatus: (s) => onStatus?.call(s),
      onError: (e) => onError?.call(e.errorMsg),
      debugLogging: false,
    );
    return _initialized;
  }

  /// Mulai listening. `onResult` dipanggil tiap kali ada partial / final result.
  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    String localeId = 'id_ID',
    Duration listenFor = const Duration(seconds: 15),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_initialized) {
      throw StateError('VoiceInputService.init() harus dipanggil dulu.');
    }
    await _stt.listen(
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: pauseFor,
      onResult: (SpeechRecognitionResult r) {
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
