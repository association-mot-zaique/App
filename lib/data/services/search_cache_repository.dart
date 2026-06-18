import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pictogram.dart';

class SearchCacheRepository {
  SearchCacheRepository(this._preferences);

  static const String _cacheKey = 'search_cache_v2';
  static const String _legacyCacheKey = 'search_cache_v1';
  static const int _maxQueries = 30;
  static const int _maxResultsPerQuery = 40;

  final SharedPreferences _preferences;

  List<Pictogram>? read(String query, {String language = 'es'}) {
    final map = _readRawMap();
    final key = _compositeKey(query, language);
    final entry = map[key];
    if (entry is! Map) {
      return null;
    }

    final rawItems = entry['items'];
    if (rawItems is! List) {
      return null;
    }

    final results = <Pictogram>[];
    for (final item in rawItems) {
      if (item is Map<String, dynamic>) {
        results.add(Pictogram.fromJson(item));
      } else if (item is Map) {
        results.add(Pictogram.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return results;
  }

  Future<void> write(
    String query,
    List<Pictogram> pictograms, {
    String language = 'es',
  }) {
    final map = _readRawMap();
    final key = _compositeKey(query, language);
    final trimmed = pictograms.take(_maxResultsPerQuery).toList();

    map[key] = {
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'items': trimmed.map((item) => item.toJson()).toList(),
    };

    _prune(map);
    return _preferences.setString(_cacheKey, jsonEncode(map));
  }

  int cachedQueriesCount() {
    return _readRawMap().length;
  }

  Future<void> clear() async {
    await _preferences.remove(_cacheKey);
    await _preferences.remove(_legacyCacheKey);
  }

  Map<String, dynamic> _readRawMap() {
    final raw = _preferences.getString(_cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Ignore corruption and continue with empty cache.
      }
    }

    return <String, dynamic>{};
  }

  void _prune(Map<String, dynamic> map) {
    if (map.length <= _maxQueries) {
      return;
    }

    final sortable = <MapEntry<String, dynamic>>[];
    for (final entry in map.entries) {
      sortable.add(entry);
    }

    sortable.sort((a, b) {
      final aTime = _updatedAt(a.value);
      final bTime = _updatedAt(b.value);
      return aTime.compareTo(bTime);
    });

    final removeCount = map.length - _maxQueries;
    for (var i = 0; i < removeCount; i++) {
      map.remove(sortable[i].key);
    }
  }

  int _updatedAt(dynamic value) {
    if (value is Map && value['updatedAt'] is int) {
      return value['updatedAt'] as int;
    }
    return 0;
  }

  String _compositeKey(String query, String language) {
    final normalizedLanguage = language.trim().toLowerCase();
    final normalizedQuery = query.trim().toLowerCase();
    return '$normalizedLanguage::$normalizedQuery';
  }
}
