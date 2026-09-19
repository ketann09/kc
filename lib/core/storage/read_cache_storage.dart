import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Represents an envelope containing cached read-only data and its fetch timestamp.
class ReadCacheEntry<T> {
  final T data;
  final DateTime cachedAt;

  const ReadCacheEntry({
    required this.data,
    required this.cachedAt,
  });

  /// Evaluates whether this entry is usable within an optional maxAge duration.
  bool isUsable({Duration? maxAge}) {
    if (maxAge == null) return true;
    return DateTime.now().difference(cachedAt) <= maxAge;
  }
}

/// Abstract contract for caching read-only backend query results.
abstract class ReadCacheStorage {
  /// Persists a single domain item.
  Future<void> save<T>({
    required String key,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
  });

  /// Retrieves a single domain item envelope, or null if missing/corrupt.
  Future<ReadCacheEntry<T>?> get<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  });

  /// Persists a list of domain items.
  Future<void> saveList<T>({
    required String key,
    required List<T> data,
    required Map<String, dynamic> Function(T) toJson,
  });

  /// Retrieves a list of domain items envelope, or null if missing/corrupt.
  Future<ReadCacheEntry<List<T>>?> getList<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  });

  /// Removes a cached entry by key.
  Future<void> remove(String key);

  /// Clears all read-cache entries.
  Future<void> clear();
}

/// SharedPreferences implementation of ReadCacheStorage with defensive JSON handling.
class SharedPreferencesReadCacheStorage implements ReadCacheStorage {
  static const String _keyPrefix = 'read_cache_';
  static const String collectorDashboardLotsKey = 'collector_recent_lots';
  static const String collectorLiveRatesKey = 'collector_live_rates';
  static const String recyclerIncomingLotsKey = 'recycler_incoming_lots';
  static const String collectorTransactionsKey = 'collector_transactions';

  final SharedPreferences? _prefsInstance;

  SharedPreferencesReadCacheStorage({SharedPreferences? prefs})
      : _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  @override
  Future<void> save<T>({
    required String key,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final prefs = await _getPrefs();
      final envelope = {
        'cachedAt': DateTime.now().toUtc().toIso8601String(),
        'payload': toJson(data),
      };
      await prefs.setString('$_keyPrefix$key', jsonEncode(envelope));
    } catch (_) {
      // Defensive: ignore write failures
    }
  }

  @override
  Future<ReadCacheEntry<T>?> get<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString('$_keyPrefix$key');
      if (raw == null || raw.trim().isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final cachedAtStr = decoded['cachedAt']?.toString();
      final cachedAt = cachedAtStr != null
          ? DateTime.tryParse(cachedAtStr)?.toLocal() ?? DateTime.now()
          : DateTime.now();

      final payload = decoded['payload'];
      if (payload is Map<String, dynamic>) {
        return ReadCacheEntry(data: fromJson(payload), cachedAt: cachedAt);
      } else if (payload is Map) {
        return ReadCacheEntry(
          data: fromJson(Map<String, dynamic>.from(payload)),
          cachedAt: cachedAt,
        );
      }
      return null;
    } catch (_) {
      // Defensive: corrupt or unparseable JSON returns null safely
      return null;
    }
  }

  @override
  Future<void> saveList<T>({
    required String key,
    required List<T> data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final prefs = await _getPrefs();
      final envelope = {
        'cachedAt': DateTime.now().toUtc().toIso8601String(),
        'payload': data.map((item) => toJson(item)).toList(),
      };
      await prefs.setString('$_keyPrefix$key', jsonEncode(envelope));
    } catch (_) {
      // Defensive: ignore write failures
    }
  }

  @override
  Future<ReadCacheEntry<List<T>>?> getList<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString('$_keyPrefix$key');
      if (raw == null || raw.trim().isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final cachedAtStr = decoded['cachedAt']?.toString();
      final cachedAt = cachedAtStr != null
          ? DateTime.tryParse(cachedAtStr)?.toLocal() ?? DateTime.now()
          : DateTime.now();

      final payload = decoded['payload'];
      if (payload is List) {
        final list = <T>[];
        for (final item in payload) {
          if (item is Map<String, dynamic>) {
            list.add(fromJson(item));
          } else if (item is Map) {
            list.add(fromJson(Map<String, dynamic>.from(item)));
          }
        }
        return ReadCacheEntry(data: list, cachedAt: cachedAt);
      }
      return null;
    } catch (_) {
      // Defensive: corrupt JSON returns null safely
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove('$_keyPrefix$key');
  }

  @override
  Future<void> clear() async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
