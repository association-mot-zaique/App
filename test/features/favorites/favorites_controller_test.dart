import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/pictogram.dart';
import 'package:mot_zaique/data/services/favorites_repository.dart';
import 'package:mot_zaique/features/favorites/favorites_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoritesController', () {
    test('load restores favorites from repository', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_pictograms_v1': [
          jsonEncode({
            'id': 42,
            'label': 'jugar',
            'tags': ['play'],
            'language': 'es',
          }),
        ],
      });

      final preferences = await SharedPreferences.getInstance();
      final repository = FavoritesRepository(preferences);
      final controller = FavoritesController(repository);

      await controller.load();

      expect(controller.favorites, hasLength(1));
      expect(controller.isFavorite(42), isTrue);
    });

    test('toggleFavorite adds and removes a pictogram', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = FavoritesRepository(preferences);
      final controller = FavoritesController(repository);

      const pictogram = Pictogram(
        id: 7,
        label: 'beber',
        tags: ['drink'],
        language: 'es',
      );

      await controller.load();
      await controller.toggleFavorite(pictogram);

      expect(controller.isFavorite(7), isTrue);
      expect(controller.favorites, hasLength(1));

      await controller.toggleFavorite(pictogram);

      expect(controller.isFavorite(7), isFalse);
      expect(controller.favorites, isEmpty);
    });
  });
}
