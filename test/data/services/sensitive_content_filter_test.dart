import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/pictogram.dart';
import 'package:mot_zaique/data/services/sensitive_content_filter.dart';

void main() {
  group('SensitiveContentFilter', () {
    test('blocks a pictogram flagged violent by ARASAAC', () {
      const picto = Pictogram(id: 8160, label: 'tuer', violence: true);
      expect(SensitiveContentFilter.isBlocked(picto), isTrue);
    });

    test('blocks a pictogram flagged sexual by ARASAAC', () {
      const picto = Pictogram(id: 1, label: 'x', sex: true);
      expect(SensitiveContentFilter.isBlocked(picto), isTrue);
    });

    test('blocks unflagged weapons through the label blocklist', () {
      // ARASAAC does not flag these as violent (verified on the API):
      // the blocklist is the second net.
      const gun = Pictogram(id: 2831, label: 'pistolet');
      const waterGun = Pictogram(id: 9137, label: 'pistolet à eau');
      const war = Pictogram(id: 12256, label: 'guerre');

      expect(SensitiveContentFilter.isBlocked(gun), isTrue);
      expect(SensitiveContentFilter.isBlocked(waterGun), isTrue);
      expect(SensitiveContentFilter.isBlocked(war), isTrue);
    });

    test('blocks through tags too', () {
      const picto = Pictogram(id: 2, label: 'objet', tags: ['weapon']);
      expect(SensitiveContentFilter.isBlocked(picto), isTrue);
    });

    test('matches whole words only, not substrings', () {
      // "charme" contains "arme", "skill" contains "kill": everyday words
      // must never be blocked by accident.
      const charm = Pictogram(id: 3, label: 'charme');
      const skill = Pictogram(id: 4, label: 'skill');
      const warm = Pictogram(id: 5, label: 'warm');

      expect(SensitiveContentFilter.isBlocked(charm), isFalse);
      expect(SensitiveContentFilter.isBlocked(skill), isFalse);
      expect(SensitiveContentFilter.isBlocked(warm), isFalse);
    });

    test('blocks unflagged sexual content through the label blocklist', () {
      // Not flagged sex=true by ARASAAC (verified on the API).
      const sexWord = Pictogram(id: 10345, label: 'sexe');
      const genitals = Pictogram(
        id: 39699,
        label: 'toucher les parties génitales',
      );

      expect(SensitiveContentFilter.isBlocked(sexWord), isTrue);
      expect(SensitiveContentFilter.isBlocked(genitals), isTrue);
    });

    test('keeps everyday CAA vocabulary', () {
      const eat = Pictogram(id: 6, label: 'manger');
      const knife = Pictogram(id: 7, label: 'couteau');
      const blood = Pictogram(id: 8, label: 'prise de sang');

      expect(SensitiveContentFilter.isBlocked(eat), isFalse);
      expect(SensitiveContentFilter.isBlocked(knife), isFalse);
      expect(SensitiveContentFilter.isBlocked(blood), isFalse);
    });

    test('violence and sex flags survive a cache round-trip', () {
      // The filter also runs on cached results: the flags must be persisted.
      const picto = Pictogram(id: 9, label: 'tuer', violence: true, sex: true);
      final restored = Pictogram.fromJson(picto.toJson());

      expect(restored.violence, isTrue);
      expect(restored.sex, isTrue);
      expect(SensitiveContentFilter.isBlocked(restored), isTrue);
    });
  });
}
