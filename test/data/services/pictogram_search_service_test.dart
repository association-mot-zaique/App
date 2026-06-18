import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mot_zaique/data/services/arasaac_api.dart';
import 'package:mot_zaique/data/services/pictogram_search_service.dart';
import 'package:mot_zaique/data/services/search_cache_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ArasaacSearchService', () {
    test('returns network results and stores in cache', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final cache = SearchCacheRepository(preferences);

      final client = MockClient((request) async {
        return http.Response(
          '[{"_id":77,"keywords":[{"keyword":"hello"}],"tags":[]}]',
          200,
        );
      });

      final service = ArasaacSearchService(
        api: ArasaacApi(client: client),
        cache: cache,
      );

      final result = await service.search(
        'hello',
        language: 'en',
        offlineOnly: false,
        onlyAacPictograms: false,
        onlySchematicPictograms: false,
        minDownloads: 0,
      );

      expect(result.fromCache, isFalse);
      expect(result.pictograms, hasLength(1));
      expect(cache.read('hello', language: 'en'), hasLength(1));
    });

    test('returns cache in offline mode', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final cache = SearchCacheRepository(preferences);

      await cache.write('hola', const [], language: 'es');

      final service = ArasaacSearchService(
        api: ArasaacApi(
          client: MockClient((_) async => http.Response('[]', 200)),
        ),
        cache: cache,
      );

      final result = await service.search(
        'hola',
        language: 'es',
        offlineOnly: true,
        onlyAacPictograms: false,
        onlySchematicPictograms: false,
        minDownloads: 0,
      );

      expect(result.fromCache, isTrue);
      expect(result.offlineOnly, isTrue);
    });

    test('uses cache when network fails', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final cache = SearchCacheRepository(preferences);

      await cache.write('comer', const [], language: 'es');

      final service = ArasaacSearchService(
        api: ArasaacApi(
          client: MockClient((_) async => http.Response('x', 500)),
        ),
        cache: cache,
      );

      final result = await service.search(
        'comer',
        language: 'es',
        offlineOnly: false,
        onlyAacPictograms: false,
        onlySchematicPictograms: false,
        minDownloads: 0,
      );

      expect(result.fromCache, isTrue);
    });

    test(
      'deduplicates semantic results and keeps higher quality item',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final cache = SearchCacheRepository(preferences);

        final client = MockClient((request) async {
          return http.Response('''
[
  {"_id": 10, "keywords": [{"keyword": "toilettes"}], "aac": false, "schematic": false, "downloads": 5},
  {"_id": 11, "keywords": [{"keyword": "toilettes"}], "aac": true, "schematic": true, "downloads": 120},
  {"_id": 12, "keywords": [{"keyword": "manger"}], "aac": true, "schematic": false, "downloads": 80}
]
''', 200);
        });

        final service = ArasaacSearchService(
          api: ArasaacApi(client: client),
          cache: cache,
        );

        final result = await service.search(
          'toilettes',
          language: 'fr',
          offlineOnly: false,
          onlyAacPictograms: false,
          onlySchematicPictograms: false,
          minDownloads: 0,
        );

        expect(result.pictograms, hasLength(2));
        expect(result.pictograms.first.id, 11);
        expect(result.pictograms.map((item) => item.id), isNot(contains(10)));
      },
    );

    test('applies quality filters from settings', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final cache = SearchCacheRepository(preferences);

      final client = MockClient((request) async {
        return http.Response('''
[
  {"_id": 21, "keywords": [{"keyword": "drink"}], "aac": false, "schematic": true, "downloads": 180},
  {"_id": 22, "keywords": [{"keyword": "drink"}], "aac": true, "schematic": false, "downloads": 260},
  {"_id": 23, "keywords": [{"keyword": "drink"}], "aac": true, "schematic": true, "downloads": 40},
  {"_id": 24, "keywords": [{"keyword": "drink"}], "aac": true, "schematic": true, "downloads": 260}
]
''', 200);
      });

      final service = ArasaacSearchService(
        api: ArasaacApi(client: client),
        cache: cache,
      );

      final result = await service.search(
        'drink',
        language: 'en',
        offlineOnly: false,
        onlyAacPictograms: true,
        onlySchematicPictograms: true,
        minDownloads: 100,
      );

      expect(result.pictograms, hasLength(1));
      expect(result.pictograms.first.id, 24);
    });
  });
}
