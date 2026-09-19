import 'package:equatable/equatable.dart';
import '../../localization/app_language.dart';

abstract class AccessibilityEvent extends Equatable {
  const AccessibilityEvent();

  @override
  List<Object?> get props => [];
}

class AccessibilityInitialized extends AccessibilityEvent {
  const AccessibilityInitialized();
}

class AccessibilityLanguageChanged extends AccessibilityEvent {
  final AppLanguage language;
  const AccessibilityLanguageChanged(this.language);

  @override
  List<Object?> get props => [language];
}

class AccessibilityAudioToggled extends AccessibilityEvent {
  final bool isAudioEnabled;
  const AccessibilityAudioToggled(this.isAudioEnabled);

  @override
  List<Object?> get props => [isAudioEnabled];
}

class AccessibilitySpeakRequested extends AccessibilityEvent {
  final String text;
  final bool force;

  const AccessibilitySpeakRequested(this.text, {this.force = false});

  @override
  List<Object?> get props => [text, force];
}

class AccessibilityStopSpeechRequested extends AccessibilityEvent {
  const AccessibilityStopSpeechRequested();
}

