import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _flutterTts.setLanguage("ko-KR");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5); // 말하기 속도를 좀 더 천천히 설정
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
