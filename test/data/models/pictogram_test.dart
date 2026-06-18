import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/pictogram.dart';

void main() {
  group('Pictogram', () {
    test('fromArasaacJson parses id, label and tags', () {
      final pictogram = Pictogram.fromArasaacJson({
        '_id': 123,
        'keywords': [
          {'keyword': 'comer'},
        ],
        'tags': ['food', 'verb'],
      }, language: 'es');

      expect(pictogram.id, 123);
      expect(pictogram.label, 'comer');
      expect(pictogram.tags, ['food', 'verb']);
      expect(
        pictogram.imageUrl(),
        'https://static.arasaac.org/pictograms/123/123_300.png',
      );
    });

    test('fromArasaacJson uses fallback label when keywords are missing', () {
      final pictogram = Pictogram.fromArasaacJson({
        '_id': 44,
        'name': 'beber',
      }, language: 'es');

      expect(pictogram.label, 'beber');
    });

    test('toJson and fromJson preserve data', () {
      const original = Pictogram(
        id: 9,
        label: 'hola',
        tags: ['saludo'],
        language: 'es',
      );

      final restored = Pictogram.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.label, original.label);
      expect(restored.tags, original.tags);
      expect(restored.language, original.language);
    });
  });
}
