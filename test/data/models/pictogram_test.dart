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

    test('network pictogram is not local and omits localImagePath', () {
      const pictogram = Pictogram(id: 9, label: 'hola');
      expect(pictogram.isLocal, isFalse);
      expect(pictogram.toJson().containsKey('localImagePath'), isFalse);
    });

    test('local pictogram round-trips its image path and is local', () {
      const original = Pictogram(
        id: 1000000005,
        label: 'maison',
        localImagePath: '/data/app/classeur/images/picto_5.png',
      );

      expect(original.isLocal, isTrue);

      final restored = Pictogram.fromJson(original.toJson());
      expect(restored.isLocal, isTrue);
      expect(restored.localImagePath, original.localImagePath);
      expect(restored.label, 'maison');
    });

    test('imageUrl only requests variants that ARASAAC actually serves', () {
      const pictogram = Pictogram(id: 2462, label: 'querer');

      // 100 does not exist server-side (404, broken thumbnail): it must be
      // promoted to the closest real variant.
      expect(pictogram.imageUrl(size: 100), contains('2462_300.png'));
      expect(pictogram.imageUrl(size: 300), contains('2462_300.png'));
      expect(pictogram.imageUrl(size: 400), contains('2462_500.png'));
      expect(pictogram.imageUrl(size: 900), contains('2462_2500.png'));
    });
  });
}
