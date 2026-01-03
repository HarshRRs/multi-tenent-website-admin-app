import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _timestampSuffix = '_timestamp';
  
  // Cache TTL in seconds
  static const Map<String, int> cacheTTL = {
    'dashboard_stats': 120, // 2 minutes
    'active_orders': 30, // 30 seconds
    'menu_items': 600, // 10 minutes
    'user_profile': 3600, // 1 hour
    'reservations': 300, // 5 minutes
    'transactions': 300, // 5 minutes
  };

  Future<T?> getCached<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$cacheKey$_timestampSuffix';

    // Check if cache exists
    final cachedData = prefs.getString(cacheKey);
    final timestamp = prefs.getInt(timestampKey);

    if (cachedData == null || timestamp == null) {
      return null;
    }

    // Check if cache is still valid
    final ttl = cacheTTL[key] ?? 300; // Default 5 minutes
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    if (now - timestamp > ttl) {
      // Cache expired
      await invalidate(key);
      return null;
    }

    try {
      final json = jsonDecode(cachedData) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<List<T>?> getCachedList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$cacheKey$_timestampSuffix';

    final cachedData = prefs.getString(cacheKey);
    final timestamp = prefs.getInt(timestampKey);

    if (cachedData == null || timestamp == null) {
      return null;
    }

    final ttl = cacheTTL[key] ?? 300;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    if (now - timestamp > ttl) {
      await invalidate(key);
      return null;
    }

    try {
      final jsonList = jsonDecode(cachedData) as List;
      return jsonList.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> cache(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$cacheKey$_timestampSuffix';

    final jsonString = jsonEncode(data);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await prefs.setString(cacheKey, jsonString);
    await prefs.setInt(timestampKey, timestamp);
  }

  Future<void> invalidate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$cacheKey$_timestampSuffix';

    await prefs.remove(cacheKey);
    await prefs.remove(timestampKey);
  }

  Future<void> invalidateAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        await prefs.remove(key);
      }
    }
  }

  Future<bool> isCacheValid(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$cacheKey$_timestampSuffix';

    final timestamp = prefs.getInt(timestampKey);
    if (timestamp == null) return false;

    final ttl = cacheTTL[key] ?? 300;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return (now - timestamp) <= ttl;
  }
}
