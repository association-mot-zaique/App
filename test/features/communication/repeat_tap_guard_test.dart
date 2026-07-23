import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/features/communication/repeat_tap_guard.dart';

void main() {
  group('RepeatTapGuard', () {
    final t0 = DateTime(2026, 7, 23, 12, 0, 0);

    test('accepts the first tap', () {
      final guard = RepeatTapGuard();
      expect(guard.accept(1, now: t0), isTrue);
    });

    test('blocks a fast repeat of the same pictogram', () {
      final guard = RepeatTapGuard(window: const Duration(milliseconds: 400));
      expect(guard.accept(1, now: t0), isTrue);
      expect(
        guard.accept(1, now: t0.add(const Duration(milliseconds: 200))),
        isFalse,
      );
    });

    test('accepts a deliberate repeat after the window', () {
      final guard = RepeatTapGuard(window: const Duration(milliseconds: 400));
      expect(guard.accept(1, now: t0), isTrue);
      expect(
        guard.accept(1, now: t0.add(const Duration(milliseconds: 600))),
        isTrue,
      );
    });

    test('a different pictogram is always accepted immediately', () {
      final guard = RepeatTapGuard(window: const Duration(milliseconds: 400));
      expect(guard.accept(1, now: t0), isTrue);
      expect(
        guard.accept(2, now: t0.add(const Duration(milliseconds: 50))),
        isTrue,
      );
    });
  });
}
