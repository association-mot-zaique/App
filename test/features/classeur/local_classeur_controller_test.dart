import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/services/local_classeur_repository.dart';
import 'package:mot_zaique/features/classeur/local_classeur_controller.dart';

void main() {
  late Directory tempDir;
  late LocalClasseurController controller;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('classeur_ctrl_test');
    final repository =
        LocalClasseurRepository(Directory('${tempDir.path}/classeur'));
    controller = LocalClasseurController(repository);
    await controller.load();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('LocalClasseurController categories (US-1.05)', () {
    test('add, rename and delete a category', () async {
      await controller.addCategory('Besoins');
      expect(controller.classeur.categories, hasLength(1));
      final id = controller.classeur.categories.single.id;

      await controller.renameCategory(id, 'Besoins essentiels');
      expect(controller.classeur.categories.single.name, 'Besoins essentiels');

      await controller.deleteCategory(id);
      expect(controller.classeur.categories, isEmpty);
    });

    test('blank category name is ignored', () async {
      final added = await controller.addCategory('   ');
      expect(added, isFalse);
      expect(controller.classeur.categories, isEmpty);
    });

    test('duplicate category name is refused (case-insensitive)', () async {
      final first = await controller.addCategory('Maison');
      final dup = await controller.addCategory('  maison ');

      expect(first, isTrue);
      expect(dup, isFalse);
      expect(controller.classeur.categories, hasLength(1));
    });

    test('renaming onto an existing name is refused', () async {
      await controller.addCategory('Maison');
      await controller.addCategory('Ecole');
      final ecoleId = controller.classeur.categories
          .firstWhere((c) => c.name == 'Ecole')
          .id;

      final renamed = await controller.renameCategory(ecoleId, 'maison');
      expect(renamed, isFalse);
      expect(
        controller.classeur.categories.firstWhere((c) => c.id == ecoleId).name,
        'Ecole',
      );
    });
  });

  group('LocalClasseurController pictograms (US-1.06)', () {
    test('add a pictogram writes an image and links it', () async {
      await controller.addCategory('Besoins');
      final categoryId = controller.classeur.categories.single.id;

      await controller.addPictogram(
        label: 'manger',
        categoryId: categoryId,
        imageBytes: [1, 2, 3],
        extension: 'png',
      );

      final picto = controller.classeur.pictograms.single;
      expect(picto.label, 'manger');
      expect(picto.categoryId, categoryId);
      expect(File(controller.absoluteImagePath(picto.imagePath)).existsSync(),
          isTrue);
    });

    test('rename a pictogram', () async {
      await controller.addCategory('Besoins');
      final categoryId = controller.classeur.categories.single.id;
      await controller.addPictogram(
        label: 'manger',
        categoryId: categoryId,
        imageBytes: [1],
        extension: 'png',
      );
      final id = controller.classeur.pictograms.single.id;

      await controller.renamePictogram(id, 'boire');
      expect(controller.classeur.pictograms.single.label, 'boire');
    });

    test('delete a pictogram also removes its image file', () async {
      await controller.addCategory('Besoins');
      final categoryId = controller.classeur.categories.single.id;
      await controller.addPictogram(
        label: 'manger',
        categoryId: categoryId,
        imageBytes: [1],
        extension: 'png',
      );
      final picto = controller.classeur.pictograms.single;
      final imagePath = controller.absoluteImagePath(picto.imagePath);
      expect(File(imagePath).existsSync(), isTrue);

      await controller.deletePictogram(picto.id);
      expect(controller.classeur.pictograms, isEmpty);
      expect(File(imagePath).existsSync(), isFalse);
    });

    test('deleting a category removes its pictograms and images', () async {
      await controller.addCategory('Besoins');
      final categoryId = controller.classeur.categories.single.id;
      await controller.addPictogram(
        label: 'manger',
        categoryId: categoryId,
        imageBytes: [1],
        extension: 'png',
      );
      final imagePath =
          controller.absoluteImagePath(controller.classeur.pictograms.single.imagePath);

      await controller.deleteCategory(categoryId);
      expect(controller.classeur.pictograms, isEmpty);
      expect(File(imagePath).existsSync(), isFalse);
    });

    test('changes persist across a reload', () async {
      await controller.addCategory('Besoins');
      final categoryId = controller.classeur.categories.single.id;
      await controller.addPictogram(
        label: 'manger',
        categoryId: categoryId,
        imageBytes: [1],
        extension: 'png',
      );

      await controller.load();
      expect(controller.classeur.categories, hasLength(1));
      expect(controller.classeur.pictograms, hasLength(1));
      expect(controller.classeur.pictograms.single.label, 'manger');
    });
  });
}
