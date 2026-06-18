import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mot_zaique/data/services/arasaac_api.dart';

void main() {
  group('ArasaacApi', () {
    test('searchPictograms parses response', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.arasaac.org/api/pictograms/es/search/comer',
        );

        return http.Response(
          '[{"_id":6456,"keywords":[{"keyword":"comer"}],"tags":["food"]}]',
          200,
        );
      });

      final api = ArasaacApi(client: client);
      final results = await api.searchPictograms('comer');

      expect(results, hasLength(1));
      expect(results.first.id, 6456);
      expect(results.first.label, 'comer');
      expect(results.first.tags, ['food']);
    });

    test('searchPictograms does not call API for empty query', () async {
      var called = false;
      final client = MockClient((request) async {
        called = true;
        return http.Response('[]', 200);
      });

      final api = ArasaacApi(client: client);
      final results = await api.searchPictograms('   ');

      expect(results, isEmpty);
      expect(called, isFalse);
    });

    test('searchPictograms throws ArasaacException on server error', () async {
      final client = MockClient((request) async {
        return http.Response('error', 500);
      });

      final api = ArasaacApi(client: client);

      expect(
        () => api.searchPictograms('comer'),
        throwsA(isA<ArasaacException>()),
      );
    });
  });
}
