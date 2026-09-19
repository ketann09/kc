import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/bloc/accessibility/accessibility_bloc.dart';
import 'package:kabadiwala_connect/core/bloc/accessibility/accessibility_event.dart';
import 'package:kabadiwala_connect/core/localization/app_language.dart';
import 'package:kabadiwala_connect/core/services/tts_service.dart';
import 'package:kabadiwala_connect/core/storage/accessibility_preferences_storage.dart';

class FakeAccessibilityPreferencesStorage implements AccessibilityPreferencesStorage {
  AppLanguage savedLanguage = AppLanguage.hindi;
  bool savedAudioEnabled = false;

  @override
  Future<AppLanguage> getLanguage() async => savedLanguage;

  @override
  Future<void> setLanguage(AppLanguage language) async {
    savedLanguage = language;
  }

  @override
  Future<bool> isAudioEnabled() async => savedAudioEnabled;

  @override
  Future<void> setAudioEnabled(bool enabled) async {
    savedAudioEnabled = enabled;
  }
}

class FakeTtsService implements TtsService {
  bool initCalled = false;
  bool stopCalled = false;
  bool disposeCalled = false;
  String? lastSpokenText;
  String? lastLanguageCode;
  bool _speaking = false;

  @override
  bool get isSpeaking => _speaking;

  @override
  Future<void> init() async {
    initCalled = true;
  }

  @override
  Future<void> speak(String text, {String? languageCode}) async {
    lastSpokenText = text;
    lastLanguageCode = languageCode;
    _speaking = true;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
    _speaking = false;
  }

  @override
  Future<bool> isLanguageAvailable(String languageCode) async => true;

  @override
  void dispose() {
    disposeCalled = true;
  }
}

void main() {
  group('AccessibilityBloc Tests', () {
    late FakeAccessibilityPreferencesStorage fakeStorage;
    late FakeTtsService fakeTts;
    late AccessibilityBloc bloc;

    setUp(() {
      fakeStorage = FakeAccessibilityPreferencesStorage();
      fakeTts = FakeTtsService();
      bloc = AccessibilityBloc(storage: fakeStorage, ttsService: fakeTts);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state has default values', () {
      expect(bloc.state.language, equals(AppLanguage.hindi));
      expect(bloc.state.isAudioEnabled, isTrue);
      expect(bloc.state.isSpeaking, isFalse);
      expect(bloc.state.isInitialized, isFalse);
    });

    test('AccessibilityInitialized loads preferences from storage and initializes TTS', () async {
      fakeStorage.savedLanguage = AppLanguage.marathi;
      fakeStorage.savedAudioEnabled = true;

      bloc.add(const AccessibilityInitialized());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isInitialized, isTrue);
      expect(bloc.state.language, equals(AppLanguage.marathi));
      expect(bloc.state.isAudioEnabled, isTrue);
      expect(fakeTts.initCalled, isTrue);
    });

    test('AccessibilityLanguageChanged updates state and persists to storage', () async {
      bloc.add(const AccessibilityLanguageChanged(AppLanguage.english));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.language, equals(AppLanguage.english));
      expect(fakeStorage.savedLanguage, equals(AppLanguage.english));
    });

    test('AccessibilityAudioToggled updates state, persists, and stops speech when disabled', () async {
      bloc.add(const AccessibilityAudioToggled(true));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isAudioEnabled, isTrue);
      expect(fakeStorage.savedAudioEnabled, isTrue);

      bloc.add(const AccessibilityAudioToggled(false));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isAudioEnabled, isFalse);
      expect(bloc.state.isSpeaking, isFalse);
      expect(fakeStorage.savedAudioEnabled, isFalse);
      expect(fakeTts.stopCalled, isTrue);
    });

    test('AccessibilitySpeakRequested does not speak when audio is disabled and force is false', () async {
      bloc.add(const AccessibilityAudioToggled(false));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const AccessibilitySpeakRequested('नमस्ते कबाड़ी', force: false));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeTts.lastSpokenText, isNull);
    });

    test('AccessibilitySpeakRequested speaks when force is true even if audio is disabled', () async {
      bloc.add(const AccessibilitySpeakRequested('नमस्ते कबाड़ी', force: true));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeTts.lastSpokenText, equals('नमस्ते कबाड़ी'));
      expect(fakeTts.lastLanguageCode, equals('hi-IN'));
      expect(bloc.state.lastSpokenText, equals('नमस्ते कबाड़ी'));
    });

    test('AccessibilitySpeakRequested speaks when audio is enabled', () async {
      bloc.add(const AccessibilityAudioToggled(true));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const AccessibilitySpeakRequested('रीसाइक्लर डैशबोर्ड'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeTts.lastSpokenText, equals('रीसाइक्लर डैशबोर्ड'));
    });

    test('AccessibilityStopSpeechRequested stops speech and updates state', () async {
      bloc.add(const AccessibilityStopSpeechRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeTts.stopCalled, isTrue);
      expect(bloc.state.isSpeaking, isFalse);
    });
  });
}
