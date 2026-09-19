import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/tts_service.dart';
import '../../storage/accessibility_preferences_storage.dart';
import 'accessibility_event.dart';
import 'accessibility_state.dart';

class AccessibilityBloc extends Bloc<AccessibilityEvent, AccessibilityState> {
  final AccessibilityPreferencesStorage storage;
  final TtsService ttsService;

  AccessibilityBloc({
    required this.storage,
    required this.ttsService,
  }) : super(const AccessibilityState()) {
    on<AccessibilityInitialized>(_onInitialized);
    on<AccessibilityLanguageChanged>(_onLanguageChanged);
    on<AccessibilityAudioToggled>(_onAudioToggled);
    on<AccessibilitySpeakRequested>(_onSpeakRequested);
    on<AccessibilityStopSpeechRequested>(_onStopSpeechRequested);
  }

  Future<void> _onInitialized(
    AccessibilityInitialized event,
    Emitter<AccessibilityState> emit,
  ) async {
    final language = await storage.getLanguage();
    final isAudioEnabled = await storage.isAudioEnabled();
    await ttsService.init();
    emit(state.copyWith(
      language: language,
      isAudioEnabled: isAudioEnabled,
      isInitialized: true,
    ));
  }

  Future<void> _onLanguageChanged(
    AccessibilityLanguageChanged event,
    Emitter<AccessibilityState> emit,
  ) async {
    await storage.setLanguage(event.language);
    emit(state.copyWith(language: event.language));
  }

  Future<void> _onAudioToggled(
    AccessibilityAudioToggled event,
    Emitter<AccessibilityState> emit,
  ) async {
    await storage.setAudioEnabled(event.isAudioEnabled);
    if (!event.isAudioEnabled) {
      await ttsService.stop();
      emit(state.copyWith(isAudioEnabled: false, isSpeaking: false));
    } else {
      emit(state.copyWith(isAudioEnabled: true));
    }
  }

  Future<void> _onSpeakRequested(
    AccessibilitySpeakRequested event,
    Emitter<AccessibilityState> emit,
  ) async {
    // If not forced and audio assistance is disabled, do not speak
    if (!event.force && !state.isAudioEnabled) {
      return;
    }
    if (event.text.trim().isEmpty) return;

    emit(state.copyWith(
      isSpeaking: true,
      lastSpokenText: event.text,
    ));

    await ttsService.speak(
      event.text,
      languageCode: state.language.ttsLocale,
    );

    emit(state.copyWith(isSpeaking: ttsService.isSpeaking));
  }

  Future<void> _onStopSpeechRequested(
    AccessibilityStopSpeechRequested event,
    Emitter<AccessibilityState> emit,
  ) async {
    await ttsService.stop();
    emit(state.copyWith(isSpeaking: false));
  }

  @override
  Future<void> close() {
    ttsService.dispose();
    return super.close();
  }
}

