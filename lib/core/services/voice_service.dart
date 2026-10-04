import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  Future<bool> initialize() async {
    try {
      return await _speech.initialize();
    } catch (e) {
      return false;
    }
  }

  Future<bool> startListening(Function(String) onResult) async {
    if (_isListening) return false;
    
    final available = await initialize();
    if (!available) return false;
    
    _isListening = true;
    _recognizedText = '';
    
    _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        onResult(_recognizedText);
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
    );
    
    return true;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    
    await _speech.stop();
    _isListening = false;
  }

  Future<void> cancelListening() async {
    if (!_isListening) return;
    
    await _speech.cancel();
    _isListening = false;
    _recognizedText = '';
  }

  Future<bool> get isAvailable async => await initialize();
}

final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});
