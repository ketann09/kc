import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_language.dart';

abstract class AccessibilityPreferencesStorage {
  Future<AppLanguage> getLanguage();
  Future<void> setLanguage(AppLanguage language);
  Future<bool> isAudioEnabled();
  Future<void> setAudioEnabled(bool enabled);
}

class SharedPreferencesAccessibilityStorage
    implements AccessibilityPreferencesStorage {
  static const String _keyLanguage = 'kc_selected_language';
  static const String _keyAudioEnabled = 'kc_audio_assistance_enabled';

  final SharedPreferences? _prefsInstance;

  SharedPreferencesAccessibilityStorage({SharedPreferences? prefs})
      : _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  @override
  Future<AppLanguage> getLanguage() async {
    final prefs = await _getPrefs();
    final String? code = prefs.getString(_keyLanguage);
    return AppLanguage.fromCode(code);
  }

  @override
  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyLanguage, language.code);
  }

  @override
  Future<bool> isAudioEnabled() async {
    final prefs = await _getPrefs();
    // Default to true for accessibility support in low-literacy demo
    return prefs.getBool(_keyAudioEnabled) ?? true;
  }

  @override
  Future<void> setAudioEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyAudioEnabled, enabled);
  }
}
