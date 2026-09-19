import 'package:equatable/equatable.dart';
import '../../localization/app_language.dart';

class AccessibilityState extends Equatable {
  final AppLanguage language;
  final bool isAudioEnabled;
  final bool isSpeaking;
  final String? lastSpokenText;
  final bool isInitialized;

  const AccessibilityState({
    this.language = AppLanguage.hindi,
    this.isAudioEnabled = true,
    this.isSpeaking = false,
    this.lastSpokenText,
    this.isInitialized = false,
  });

  AccessibilityState copyWith({
    AppLanguage? language,
    bool? isAudioEnabled,
    bool? isSpeaking,
    String? lastSpokenText,
    bool? isInitialized,
  }) {
    return AccessibilityState(
      language: language ?? this.language,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      lastSpokenText: lastSpokenText ?? this.lastSpokenText,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [
        language,
        isAudioEnabled,
        isSpeaking,
        lastSpokenText,
        isInitialized,
      ];
}

