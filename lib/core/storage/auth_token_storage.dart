import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthTokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveAccessToken(String accessToken);

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clearTokens();

  Future<bool> hasValidToken();
}

class SharedPreferencesAuthTokenStorage implements AuthTokenStorage {
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';

  final SharedPreferences? _prefsInstance;

  SharedPreferencesAuthTokenStorage({SharedPreferences? prefs})
      : _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyAccessToken, accessToken.trim());
    await prefs.setString(_keyRefreshToken, refreshToken.trim());
  }

  @override
  Future<void> saveAccessToken(String accessToken) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyAccessToken, accessToken.trim());
  }

  @override
  Future<String?> getAccessToken() async {
    final prefs = await _getPrefs();
    final token = prefs.getString(_keyAccessToken);
    if (token == null || token.trim().isEmpty) return null;
    return token.trim();
  }

  @override
  Future<String?> getRefreshToken() async {
    final prefs = await _getPrefs();
    final token = prefs.getString(_keyRefreshToken);
    if (token == null || token.trim().isEmpty) return null;
    return token.trim();
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

