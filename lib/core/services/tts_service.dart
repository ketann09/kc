import 'dart:developer' as developer;
import 'package:flutter_tts/flutter_tts.dart';

/// Abstract contract for Text-To-Speech functionality.
abstract class TtsService {
  Future<void> init();
  Future<void> speak(String text, {String? languageCode});
  Future<void> stop();
  Future<bool> isLanguageAvailable(String languageCode);
  bool get isSpeaking;
  void dispose();
}

/// Production implementation of [TtsService] wrapping [FlutterTts].
///
/// Features:
/// - Preemption: stops previous speech before speaking new text to prevent overlap.
/// - Language fallback: Marathi (mr-IN) -> Hindi (hi-IN) -> English (en-IN).
/// - Safe error handling: never crashes or blocks UI if TTS engine fails.
class FlutterTtsServiceImpl implements TtsService {
  final FlutterTts _flutterTts;
  bool _initialized = false;
  bool _isSpeaking = false;

  FlutterTtsServiceImpl({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((dynamic msg) {
        _isSpeaking = false;
        developer.log('TTS engine error: $msg', name: 'TtsService');
      });

      _initialized = true;
    } catch (e, stack) {
      _isSpeaking = false;
      developer.log('Failed to initialize FlutterTts: $e',
          name: 'TtsService', error: e, stackTrace: stack);
    }
  }

  @override
  Future<bool> isLanguageAvailable(String languageCode) async {
    try {
      final dynamic result = await _flutterTts.isLanguageAvailable(languageCode);
      if (result == 1 || result == true || result == '1') {
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error checking language availability for $languageCode: $e',
          name: 'TtsService');
      return false;
    }
  }

  @override
  Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;

    try {
      if (!_initialized) {
        await init();
      }

      // Preemption: cancel any currently playing utterance before new speech
      await stop();

      final String resolvedLang = await _resolveLanguageCode(languageCode);
      await _flutterTts.setLanguage(resolvedLang);

      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (e, stack) {
      _isSpeaking = false;
      developer.log('TTS speak failure for text "$text": $e',
          name: 'TtsService', error: e, stackTrace: stack);
    }
  }

  Future<String> _resolveLanguageCode(String? preferredCode) async {
    if (preferredCode == null || preferredCode.isEmpty) {
      return 'hi-IN';
    }

    final code = preferredCode.toLowerCase();
    if (code.startsWith('mr')) {
      // Check if Marathi voice is available on-device
      final mrAvailable = await isLanguageAvailable('mr-IN');
      if (mrAvailable) return 'mr-IN';

      // Marathi fallback to Hindi voice
      final hiAvailable = await isLanguageAvailable('hi-IN');
      if (hiAvailable) return 'hi-IN';

      // Final technical fallback
      return 'en-IN';
    }

    if (code.startsWith('hi')) {
      final hiAvailable = await isLanguageAvailable('hi-IN');
      if (hiAvailable) return 'hi-IN';
      return 'en-IN';
    }

    return 'en-IN';
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      _isSpeaking = false;
      developer.log('TTS stop error: $e', name: 'TtsService');
    }
  }

  @override
  void dispose() {
    try {
      _flutterTts.stop();
    } catch (_) {}
    _isSpeaking = false;
    _initialized = false;
  }
}

/// In-memory mock implementation of [TtsService] for automated testing.
class MockTtsService implements TtsService {
  bool _isSpeaking = false;
  final List<String> spokenUtterances = [];
  final List<String> spokenLanguages = [];
  String? lastSpokenText;
  String? lastLanguageCode;
  bool shouldFail = false;
  Set<String> availableLanguages = {'hi-IN', 'mr-IN', 'en-IN'};

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> init() async {}

  @override
  Future<bool> isLanguageAvailable(String languageCode) async {
    return availableLanguages.contains(languageCode);
  }

  @override
  Future<void> speak(String text, {String? languageCode}) async {
    if (shouldFail) {
      throw Exception('Mock TTS failure');
    }
    // Preempt
    await stop();
    _isSpeaking = true;
    lastSpokenText = text;
    lastLanguageCode = languageCode ?? 'hi-IN';
    spokenUtterances.add(text);
    spokenLanguages.add(lastLanguageCode!);
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
  }

  @override
  void dispose() {
    _isSpeaking = false;
  }

  void clear() {
    spokenUtterances.clear();
    spokenLanguages.clear();
    lastSpokenText = null;
    lastLanguageCode = null;
    _isSpeaking = false;
    shouldFail = false;
  }
}

