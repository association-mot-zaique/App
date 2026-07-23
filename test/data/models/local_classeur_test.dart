import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/local_classeur.dart';

void main() {
  group('LocalClasseur', () {
    test('empty classeur starts with fresh id counters', () {
      final classeur = LocalClasseur.empty();

      expect(classeur.isEmpty, isTrue);
      expect(classeur.nextCategoryId, 1);
      expect(classeur.nextPictogramId, 1);
    });

    test('addCategory assigns id and increments the counter', () {
      final result = LocalClasseur.empty().addCategory('Besoins');

      expect(result.category.id, 1);
      expect(result.category.sortOrder, 0);
      expect(result.classeur.nextCategoryId, 2);
      expect(result.classeur.categories, hasLength(1));
    });

    test('addPictogram scopes sortOrder to its category', () {
      var classeur = LocalClasseur.empty();
      final cat = classeur.addCategory('Besoins');
      classeur = cat.classeur;

      final first = classeur.addPictogram(
        label: 'manger',
        imagePath: 'images/picto_1.png',
        categoryId: cat.category.id,
      );
      classeur = first.classeur;
      final second = classeur.addPictogram(
        label: 'boire',
        imagePath: 'images/picto_2.png',
        categoryId: cat.category.id,
      );
      classeur = second.classeur;

      expect(first.pictogram.id, 1);
      expect(second.pictogram.id, 2);
      expect(first.pictogram.sortOrder, 0);
      expect(second.pictogram.sortOrder, 1);
      expect(classeur.pictogramsIn(cat.category.id), hasLength(2));
      expect(classeur.nextPictogramId, 3);
    });

    test('categoriesSorted and pictogramsIn respect sortOrder', () {
      var classeur = LocalClasseur.empty();
      final a = classeur.addCategory('A');
      classeur = a.classeur;
      final b = classeur.addCategory('B');
      classeur = b.classeur;

      final ids = classeur.categoriesSorted.map((c) => c.name).toList();
      expect(ids, ['A', 'B']);
    });

    test('favorites returns only flagged pictograms', () {
      var classeur = LocalClasseur.empty();
      final cat = classeur.addCategory('Besoins');
      classeur = cat.classeur;
      classeur = classeur
          .addPictogram(
            label: 'manger',
            imagePath: 'images/picto_1.png',
            categoryId: cat.category.id,
            isFavorite: true,
          )
          .classeur;
      classeur = classeur
          .addPictogram(
            label: 'boire',
            imagePath: 'images/picto_2.png',
            categoryId: cat.category.id,
          )
          .classeur;

      expect(classeur.favorites, hasLength(1));
      expect(classeur.favorites.single.label, 'manger');
    });

    test('toJson/fromJson round-trip preserves data', () {
      var classeur = LocalClasseur.empty();
      final cat = classeur.addCategory('Besoins');
      classeur = cat.classeur;
      classeur = classeur
          .addPictogram(
            label: 'manger',
            imagePath: 'images/picto_1.png',
            categoryId: cat.category.id,
            isFavorite: true,
          )
          .classeur;

      final restored = LocalClasseur.fromJson(classeur.toJson());

      expect(restored.schemaVersion, LocalClasseur.currentSchemaVersion);
      expect(restored.nextCategoryId, classeur.nextCategoryId);
      expect(restored.nextPictogramId, classeur.nextPictogramId);
      expect(restored.categories.single.name, 'Besoins');
      final picto = restored.pictograms.single;
      expect(picto.label, 'manger');
      expect(picto.imagePath, 'images/picto_1.png');
      expect(picto.isFavorite, isTrue);
    });
  });
}
