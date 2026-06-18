import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PinValidationStatus { success, invalid, blocked }

class PinValidationResult {
  const PinValidationResult({
    required this.status,
    required this.failedAttempts,
    required this.maxAttempts,
    this.blockedFor,
  });

  final PinValidationStatus status;
  final int failedAttempts;
  final int maxAttempts;
  final Duration? blockedFor;

  int get remainingAttempts {
    final remaining = maxAttempts - failedAttempts;
    return remaining < 0 ? 0 : remaining;
  }
}

class PinSetupResult {
  const PinSetupResult({required this.recoveryCode});

  final String recoveryCode;
}

class PinRepository {
  PinRepository(
    this._preferences, {
    DateTime Function()? nowProvider,
    String Function()? recoveryCodeGenerator,
    Random? random,
  }) : _nowProvider = nowProvider ?? DateTime.now,
       _recoveryCodeGenerator = recoveryCodeGenerator,
       _random = random ?? Random.secure();

  static const String _pinKey = 'favorites_pin_hash_v3';
  static const String _pinSaltKey = 'favorites_pin_salt_v3';
  static const String _recoveryKey = 'favorites_recovery_hash_v3';
  static const String _recoverySaltKey = 'favorites_recovery_salt_v3';
  static const String _legacyPinKey = 'favorites_pin_hash_v2';
  static const String _legacyRecoveryKey = 'favorites_recovery_hash_v1';
  static const String _failedAttemptsKey = 'favorites_pin_failed_attempts_v1';
  static const String _blockedUntilKey = 'favorites_pin_blocked_until_v1';

  static const int maxAttempts = 5;
  static const Duration lockDuration = Duration(minutes: 2);
  static const int _iterations = 20000;
  static const int _saltLengthBytes = 16;
  static const int _derivedKeyLengthBytes = 32;

  final SharedPreferences _preferences;
  final DateTime Function() _nowProvider;
  final String Function()? _recoveryCodeGenerator;
  final Random _random;

  bool hasPin() {
    final current = _preferences.getString(_pinKey);
    if (current != null && current.isNotEmpty) {
      return true;
    }
    final legacy = _preferences.getString(_legacyPinKey);
    return legacy != null && legacy.isNotEmpty;
  }

  Future<PinSetupResult> setupPin(String pin) async {
    final recoveryCode = _generateRecoveryCode();

    await _writeSaltedHash(pin, keyHash: _pinKey, keySalt: _pinSaltKey);
    await _writeSaltedHash(
      recoveryCode,
      keyHash: _recoveryKey,
      keySalt: _recoverySaltKey,
    );

    await _preferences.remove(_legacyPinKey);
    await _preferences.remove(_legacyRecoveryKey);

    await _resetAttemptsAndBlock();

    return PinSetupResult(recoveryCode: recoveryCode);
  }

  Future<void> changePin(String pin) async {
    await _writeSaltedHash(pin, keyHash: _pinKey, keySalt: _pinSaltKey);
    await _preferences.remove(_legacyPinKey);
    await _resetAttemptsAndBlock();
  }

  Future<PinValidationResult> verifyPin(String pin) async {
    final blockedFor = await remainingLockDuration();
    if (blockedFor != null) {
      final failedAttempts = _preferences.getInt(_failedAttemptsKey) ?? 0;
      return PinValidationResult(
        status: PinValidationStatus.blocked,
        failedAttempts: failedAttempts,
        maxAttempts: maxAttempts,
        blockedFor: blockedFor,
      );
    }

    final matches = await _matchesPin(pin);

    if (matches) {
      await _resetAttemptsAndBlock();
      return const PinValidationResult(
        status: PinValidationStatus.success,
        failedAttempts: 0,
        maxAttempts: maxAttempts,
      );
    }

    final failedAttempts = (_preferences.getInt(_failedAttemptsKey) ?? 0) + 1;
    await _preferences.setInt(_failedAttemptsKey, failedAttempts);

    if (failedAttempts >= maxAttempts) {
      final blockedUntil = _nowProvider()
          .add(lockDuration)
          .millisecondsSinceEpoch;
      await _preferences.setInt(_blockedUntilKey, blockedUntil);
      return PinValidationResult(
        status: PinValidationStatus.blocked,
        failedAttempts: failedAttempts,
        maxAttempts: maxAttempts,
        blockedFor: lockDuration,
      );
    }

    return PinValidationResult(
      status: PinValidationStatus.invalid,
      failedAttempts: failedAttempts,
      maxAttempts: maxAttempts,
    );
  }

  Future<Duration?> remainingLockDuration() async {
    final blockedUntilRaw = _preferences.getInt(_blockedUntilKey);
    if (blockedUntilRaw == null || blockedUntilRaw <= 0) {
      return null;
    }

    final now = _nowProvider().millisecondsSinceEpoch;
    final remainingMs = blockedUntilRaw - now;

    if (remainingMs <= 0) {
      await _preferences.remove(_blockedUntilKey);
      return null;
    }

    return Duration(milliseconds: remainingMs);
  }

  Future<bool> resetPinWithRecoveryCode({
    required String recoveryCode,
    required String newPin,
  }) async {
    final matches = await _matchesRecovery(recoveryCode);
    if (!matches) {
      return false;
    }

    await _writeSaltedHash(newPin, keyHash: _pinKey, keySalt: _pinSaltKey);
    await _preferences.remove(_legacyPinKey);
    await _resetAttemptsAndBlock();
    return true;
  }

  Future<bool> _matchesPin(String pin) async {
    final currentHash = _preferences.getString(_pinKey);
    final currentSalt = _preferences.getString(_pinSaltKey);
    if (currentHash != null &&
        currentHash.isNotEmpty &&
        currentSalt != null &&
        currentSalt.isNotEmpty) {
      return _constantTimeEquals(_deriveHash(pin, currentSalt), currentHash);
    }

    final legacyHash = _preferences.getString(_legacyPinKey);
    if (legacyHash == null || legacyHash.isEmpty) {
      return false;
    }

    if (_legacyHash(pin) != legacyHash) {
      return false;
    }

    await _writeSaltedHash(pin, keyHash: _pinKey, keySalt: _pinSaltKey);
    await _preferences.remove(_legacyPinKey);
    return true;
  }

  Future<bool> _matchesRecovery(String recoveryCode) async {
    final currentHash = _preferences.getString(_recoveryKey);
    final currentSalt = _preferences.getString(_recoverySaltKey);
    if (currentHash != null &&
        currentHash.isNotEmpty &&
        currentSalt != null &&
        currentSalt.isNotEmpty) {
      return _constantTimeEquals(
        _deriveHash(recoveryCode, currentSalt),
        currentHash,
      );
    }

    final legacyHash = _preferences.getString(_legacyRecoveryKey);
    if (legacyHash == null || legacyHash.isEmpty) {
      return false;
    }

    if (_legacyHash(recoveryCode) != legacyHash) {
      return false;
    }

    await _writeSaltedHash(
      recoveryCode,
      keyHash: _recoveryKey,
      keySalt: _recoverySaltKey,
    );
    await _preferences.remove(_legacyRecoveryKey);
    return true;
  }

  Future<void> _resetAttemptsAndBlock() async {
    await _preferences.setInt(_failedAttemptsKey, 0);
    await _preferences.remove(_blockedUntilKey);
  }

  Future<void> _writeSaltedHash(
    String raw, {
    required String keyHash,
    required String keySalt,
  }) async {
    final salt = _generateSalt();
    final derived = _deriveHash(raw, salt);
    await _preferences.setString(keySalt, salt);
    await _preferences.setString(keyHash, derived);
  }

  String _deriveHash(String raw, String saltBase64) {
    final salt = base64Decode(saltBase64);
    final derived = _pbkdf2Sha256(
      password: utf8.encode(raw),
      salt: salt,
      iterations: _iterations,
      keyLength: _derivedKeyLengthBytes,
    );
    return base64Encode(derived);
  }

  String _generateSalt() {
    final bytes = Uint8List(_saltLengthBytes);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return base64Encode(bytes);
  }

  String _legacyHash(String raw) {
    return sha256.convert(utf8.encode(raw)).toString();
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  String _generateRecoveryCode() {
    if (_recoveryCodeGenerator != null) {
      return _recoveryCodeGenerator.call();
    }

    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final codeUnits = <int>[];

    for (var i = 0; i < 8; i++) {
      codeUnits.add(alphabet.codeUnitAt(_random.nextInt(alphabet.length)));
    }

    final raw = String.fromCharCodes(codeUnits);
    return '${raw.substring(0, 4)}-${raw.substring(4)}';
  }

  Uint8List _pbkdf2Sha256({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, password);
    const blockSize = 32;
    final blocksRequired = (keyLength + blockSize - 1) ~/ blockSize;
    final result = Uint8List(blocksRequired * blockSize);

    for (var block = 1; block <= blocksRequired; block++) {
      final blockIndexBytes = Uint8List(4)
        ..[0] = (block >> 24) & 0xff
        ..[1] = (block >> 16) & 0xff
        ..[2] = (block >> 8) & 0xff
        ..[3] = block & 0xff;

      var previous = hmac
          .convert(<int>[...salt, ...blockIndexBytes])
          .bytes;
      final accumulated = Uint8List.fromList(previous);

      for (var iteration = 1; iteration < iterations; iteration++) {
        previous = hmac.convert(previous).bytes;
        for (var byteIndex = 0; byteIndex < blockSize; byteIndex++) {
          accumulated[byteIndex] ^= previous[byteIndex];
        }
      }

      result.setRange(
        (block - 1) * blockSize,
        block * blockSize,
        accumulated,
      );
    }

    return Uint8List.sublistView(result, 0, keyLength);
  }
}
