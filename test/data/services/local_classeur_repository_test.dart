import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/local_classeur.dart';
import 'package:mot_zaique/data/services/local_classeur_repository.dart';

void main() {
  late Directory tempDir;
  late LocalClasseurRepository repository;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('classeur_test');
    repository = LocalClasseurRepository(Directory('${tempDir.path}/classeur'));
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('LocalClasseurRepository', () {
    test('load returns an empty classeur when nothing is stored', () async {
      final classeur = await repository.load();
      expect(classeur.isEmpty, isTrue);
    });

    test('reanchorImagePath rebases a stale absolute path', () {
      // Path persisted by the bande-phrase under a previous install or
      // another profile: only the classeur-relative suffix is still valid.
      const stale = '/data/old-install/profiles/abc/classeur/images/p_3.png';

      expect(
        repository.reanchorImagePath(stale),
        '${tempDir.path}/classeur/images/p_3.png',
      );
    });

    test('reanchorImagePath leaves foreign paths untouched', () {
      const foreign = '/somewhere/else/picture.png';
      expect(repository.reanchorImagePath(foreign), foreign);
    });

    test('save then load round-trips the classeur', () async {
      var classeur = LocalClasseur.empty();
      final cat = classeur.addCategory('Besoins');
      classeur = cat.classeur
          .addPictogram(
            label: 'manger',
            imagePath: 'images/picto_1.png',
            categoryId: cat.category.id,
          )
          .classeur;

      await repository.save(classeur);
      final restored = await repository.load();

      expect(restored.categories.single.name, 'Besoins');
      expect(restored.pictograms.single.label, 'manger');
    });

    test(
      'storeImageBytes writes the file and returns a relative path',
      () async {
        final relativePath = await repository.storeImageBytes(
          [1, 2, 3, 4],
          pictogramId: 3,
          extension: 'png',
        );

        expect(relativePath, 'images/picto_3.png');
        final file = File(repository.absoluteImagePath(relativePath));
        expect(await file.exists(), isTrue);
        expect(await file.readAsBytes(), [1, 2, 3, 4]);
      },
    );

    test('storeImageBytes normalizes the extension', () async {
      final relativePath = await repository.storeImageBytes(
        [0],
        pictogramId: 7,
        extension: '.JPG',
      );
      expect(relativePath, 'images/picto_7.jpg');
    });

    test('deleteImage removes the file and ignores missing files', () async {
      final relativePath = await repository.storeImageBytes(
        [9],
        pictogramId: 1,
        extension: 'png',
      );
      await repository.deleteImage(relativePath);
      expect(
        File(repository.absoluteImagePath(relativePath)).existsSync(),
        isFalse,
      );

      // Should not throw on a missing file.
      await repository.deleteImage('images/does_not_exist.png');
    });

    test(
      'export then import round-trips categories, pictos and images',
      () async {
        // Build a classeur with one category, one pictogram and its image.
        var classeur = LocalClasseur.empty();
        final category = classeur.addCategory('Maison');
        classeur = category.classeur;
        final imagePath = await repository.storeImageBytes(
          [1, 2, 3, 4],
          pictogramId: classeur.nextPictogramId,
          extension: 'png',
        );
        classeur = classeur
            .addPictogram(
              label: 'porte',
              imagePath: imagePath,
              categoryId: category.category.id,
            )
            .classeur;
        await repository.save(classeur);

        final archive = await repository.exportToZipBytes();
        expect(archive, isNotEmpty);

        // Import into a *different* root, as if on another device.
        final otherRoot = Directory('${tempDir.path}/other');
        final other = LocalClasseurRepository(otherRoot);
        final imported = await other.importFromZipBytes(archive);
        expect(imported, isTrue);

        final restored = await other.load();
        expect(restored.categories.single.name, 'Maison');
        final picto = restored.pictograms.single;
        expect(picto.label, 'porte');
        // The image travelled with the archive.
        final restoredImage = File(other.absoluteImagePath(picto.imagePath));
        expect(restoredImage.existsSync(), isTrue);
        expect(await restoredImage.readAsBytes(), [1, 2, 3, 4]);
      },
    );

    test(
      'importing a non-classeur archive is refused and changes nothing',
      () async {
        await repository.save(
          LocalClasseur.empty().addCategory('Garde').classeur,
        );

        final refused = await repository.importFromZipBytes([0, 1, 2, 3]);

        expect(refused, isFalse);
        final untouched = await repository.load();
        expect(untouched.categories.single.name, 'Garde');
      },
    );

    test('load recovers from a corrupted manifest', () async {
      final manifest = File('${repository.rootDir.path}/manifest.json');
      await manifest.parent.create(recursive: true);
      await manifest.writeAsString('{ not valid json');

      final classeur = await repository.load();
      expect(classeur.isEmpty, isTrue);
    });
  });
}
