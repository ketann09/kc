import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';

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

  /// Persists the authenticated user's profile identity for offline session restoration.
  Future<void> saveUser(UserEntity user);

  /// Retrieves the cached user profile if present and valid.
  Future<UserEntity?> getUser();

  /// Clears the cached user profile upon logout or session invalidation.
  Future<void> clearUser();
}

class SharedPreferencesAuthTokenStorage implements AuthTokenStorage {
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyCachedUser = 'auth_cached_user';

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

  @override
  Future<void> saveUser(UserEntity user) async {
    final prefs = await _getPrefs();
    final jsonMap = UserModel.fromEntity(user).toJson();
    await prefs.setString(_keyCachedUser, jsonEncode(jsonMap));
  }

  @override
  Future<UserEntity?> getUser() async {
    try {
      final prefs = await _getPrefs();
      final userJson = prefs.getString(_keyCachedUser);
      if (userJson == null || userJson.trim().isEmpty) return null;
      final dynamic decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      } else if (decoded is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(decoded));
      }
      return null;
    } catch (_) {
      // Return null defensively if cached JSON is corrupt or unparseable
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyCachedUser);
  }
}
