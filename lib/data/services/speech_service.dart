import 'package:flutter_tts/flutter_tts.dart';

abstract class SpeechService {
  Future<void> speak(String text, {required String languageCode});
  Future<void> stop();
}

class FlutterSpeechService implements SpeechService {
  FlutterSpeechService();

  final FlutterTts _flutterTts = FlutterTts();

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty) {
      return;
    }

    await _flutterTts.setLanguage(_mapTtsLanguage(languageCode));
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.stop();
    await _flutterTts.speak(cleanedText);
  }

  @override
  Future<void> stop() {
    return _flutterTts.stop();
  }

  String _mapTtsLanguage(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'fr-FR';
      case 'en':
        return 'en-US';
      case 'de':
        return 'de-DE';
      case 'it':
        return 'it-IT';
      case 'es':
      default:
        return 'es-ES';
    }
  }
}

class NoopSpeechService implements SpeechService {
  @override
  Future<void> speak(String text, {required String languageCode}) async {}

  @override
  Future<void> stop() async {}
}
