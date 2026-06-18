import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pictogram.dart';

class FavoritesRepository {
  FavoritesRepository(this._preferences);

  static const String _storageKey = 'favorite_pictograms_v1';
  final SharedPreferences _preferences;

  List<Pictogram> readFavorites() {
    final entries = _preferences.getStringList(_storageKey) ?? const [];
    final favorites = <Pictogram>[];

    for (final entry in entries) {
      try {
        final json = jsonDecode(entry);
        if (json is Map<String, dynamic>) {
          favorites.add(Pictogram.fromJson(json));
        } else if (json is Map) {
          favorites.add(Pictogram.fromJson(Map<String, dynamic>.from(json)));
        }
      } catch (_) {
        // Ignora elementos invalidos para evitar bloquear la app.
      }
    }

    return favorites;
  }

  Future<void> saveFavorites(List<Pictogram> favorites) {
    final encoded = favorites
        .map((picto) => jsonEncode(picto.toJson()))
        .toList();
    return _preferences.setStringList(_storageKey, encoded);
  }
}
