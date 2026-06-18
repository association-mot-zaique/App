import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/pictogram.dart';
import 'package:mot_zaique/data/services/search_cache_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchCacheRepository', () {
    test('write and read persist pictograms by query', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SearchCacheRepository(preferences);

      await repository.write('comer', const [
        Pictogram(id: 1, label: 'comer', tags: ['food'], language: 'es'),
      ], language: 'es');

      final restored = repository.read('comer', language: 'es');
      expect(restored, isNotNull);
      expect(restored, hasLength(1));
      expect(restored!.first.label, 'comer');
    });

    test('clear removes all cached queries', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SearchCacheRepository(preferences);

      await repository.write('beber', const [
        Pictogram(id: 2, label: 'beber', tags: ['drink'], language: 'es'),
      ], language: 'es');
      expect(repository.cachedQueriesCount(), 1);

      await repository.clear();

      expect(repository.cachedQueriesCount(), 0);
      expect(repository.read('beber', language: 'es'), isNull);
    });

    test('distinguishes entries by language', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SearchCacheRepository(preferences);

      await repository.write('casa', const [
        Pictogram(id: 10, label: 'casa', language: 'es'),
      ], language: 'es');
      await repository.write('casa', const [
        Pictogram(id: 20, label: 'maison', language: 'fr'),
      ], language: 'fr');

      final spanish = repository.read('casa', language: 'es');
      final french = repository.read('casa', language: 'fr');

      expect(spanish, hasLength(1));
      expect(spanish!.first.id, 10);
      expect(french, hasLength(1));
      expect(french!.first.id, 20);
    });
  });
}
