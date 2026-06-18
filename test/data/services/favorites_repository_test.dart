import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/pictogram.dart';
import 'package:mot_zaique/data/services/favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoritesRepository', () {
    test('saveFavorites and readFavorites persist pictograms', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = FavoritesRepository(preferences);

      const favorites = [
        Pictogram(id: 1, label: 'comer', tags: ['food'], language: 'es'),
        Pictogram(id: 2, label: 'beber', tags: ['drink'], language: 'es'),
      ];

      await repository.saveFavorites(favorites);
      final restored = repository.readFavorites();

      expect(restored, hasLength(2));
      expect(restored.first.label, 'comer');
      expect(restored.last.id, 2);
    });

    test('readFavorites ignores invalid entries', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_pictograms_v1': [
          jsonEncode({'id': 1, 'label': 'hola', 'tags': [], 'language': 'es'}),
          'invalid-json',
        ],
      });

      final preferences = await SharedPreferences.getInstance();
      final repository = FavoritesRepository(preferences);

      final restored = repository.readFavorites();

      expect(restored, hasLength(1));
      expect(restored.first.id, 1);
    });
  });
}
