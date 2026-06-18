import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/pictogram.dart';
import 'package:mot_zaique/data/services/phrase_book_repository.dart';
import 'package:mot_zaique/features/communication/phrase_book_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhraseBookController', () {
    test('persists current phrase session', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = PhraseBookRepository(preferences);
      final controller = PhraseBookController(repository);

      await controller.load();
      await controller.addToCurrent(
        const Pictogram(id: 1, label: 'hola', tags: [], language: 'es'),
      );

      expect(controller.currentText, 'hola');

      final secondController = PhraseBookController(repository);
      await secondController.load();

      expect(secondController.currentText, 'hola');
    });

    test('saveCurrentAsPhrase stores reusable phrase', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = PhraseBookRepository(preferences);
      final controller = PhraseBookController(repository);

      await controller.load();
      await controller.addToCurrent(
        const Pictogram(id: 1, label: 'quiero', tags: [], language: 'es'),
      );
      await controller.addToCurrent(
        const Pictogram(id: 2, label: 'agua', tags: [], language: 'es'),
      );

      await controller.saveCurrentAsPhrase(customName: 'Quiero agua');

      expect(controller.savedPhrases, hasLength(1));
      expect(controller.savedPhrases.first.text, 'quiero agua');
      expect(controller.savedPhrases.first.name, 'Quiero agua');
    });
  });
}
