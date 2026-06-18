import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/services/pin_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PinRepository', () {
    test('setupPin stores pin and verifies correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = PinRepository(
        preferences,
        recoveryCodeGenerator: () => 'ABCD-2345',
      );

      final setupResult = await repository.setupPin('1234');

      expect(setupResult.recoveryCode, 'ABCD-2345');
      expect(repository.hasPin(), isTrue);

      final valid = await repository.verifyPin('1234');
      expect(valid.status, PinValidationStatus.success);

      final invalid = await repository.verifyPin('0000');
      expect(invalid.status, PinValidationStatus.invalid);
      expect(invalid.remainingAttempts, PinRepository.maxAttempts - 1);
    });

    test('locks after max attempts and unlocks after lock duration', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      var now = DateTime(2026, 3, 4, 21, 0, 0);
      final repository = PinRepository(
        preferences,
        nowProvider: () => now,
        recoveryCodeGenerator: () => 'ZXCV-7788',
      );

      await repository.setupPin('1234');

      for (var i = 0; i < PinRepository.maxAttempts - 1; i++) {
        final result = await repository.verifyPin('9999');
        expect(result.status, PinValidationStatus.invalid);
      }

      final blockedResult = await repository.verifyPin('9999');
      expect(blockedResult.status, PinValidationStatus.blocked);
      expect(blockedResult.blockedFor, isNotNull);

      final blockedAgain = await repository.verifyPin('1234');
      expect(blockedAgain.status, PinValidationStatus.blocked);

      now = now.add(const Duration(minutes: 3));

      final unlocked = await repository.verifyPin('1234');
      expect(unlocked.status, PinValidationStatus.success);
    });

    test(
      'migrates legacy sha256 pin to salted hash on first successful verify',
      () async {
        final legacyHash = sha256.convert(utf8.encode('4321')).toString();
        SharedPreferences.setMockInitialValues({
          'favorites_pin_hash_v2': legacyHash,
        });
        final preferences = await SharedPreferences.getInstance();
        final repository = PinRepository(preferences);

        expect(repository.hasPin(), isTrue);

        final valid = await repository.verifyPin('4321');
        expect(valid.status, PinValidationStatus.success);

        expect(preferences.getString('favorites_pin_hash_v2'), isNull);
        expect(
          preferences.getString('favorites_pin_hash_v3'),
          isNot(isEmpty),
        );
        expect(
          preferences.getString('favorites_pin_salt_v3'),
          isNot(isEmpty),
        );

        final secondCheck = await repository.verifyPin('4321');
        expect(secondCheck.status, PinValidationStatus.success);
      },
    );

    test('resetPinWithRecoveryCode replaces pin', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = PinRepository(
        preferences,
        recoveryCodeGenerator: () => 'QWER-5566',
      );

      await repository.setupPin('1234');

      final wrongRecovery = await repository.resetPinWithRecoveryCode(
        recoveryCode: 'WRONG-CODE',
        newPin: '5678',
      );
      expect(wrongRecovery, isFalse);

      final success = await repository.resetPinWithRecoveryCode(
        recoveryCode: 'QWER-5566',
        newPin: '5678',
      );
      expect(success, isTrue);

      final validNewPin = await repository.verifyPin('5678');
      expect(validNewPin.status, PinValidationStatus.success);
    });
  });
}
