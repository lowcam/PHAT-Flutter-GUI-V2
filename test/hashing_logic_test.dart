import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:phat_flutter_gui/logic/hashing_logic.dart';
import 'package:phat_flutter_gui/constants.dart';

void main() {
  group('HashingLogic Unit Tests', () {
    test('SHA-256 hashing should be consistent and match known output', () async {
      final params = HashParams(
        userText: Uint8List.fromList(utf8.encode('password')),
        algorithm: HashAlgorithm.sha256,
        salt: Uint8List.fromList([]),
        argon2Iterations: 3,
        argon2Memory: 65536,
        argon2Parallelism: 4,
        pbkdf2Iterations: 1000,
      );

      final bytes = await HashingLogic.hashInput(params);
      final hexResult = HashingLogic.formatBytes(bytes, NumberSystem.hex);

      // Known SHA-256 for 'password'
      expect(hexResult, '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8');
    });

    test('Argon2id should fail if salt is too short', () async {
      final params = HashParams(
        userText: Uint8List.fromList(utf8.encode('password')),
        algorithm: HashAlgorithm.argon2id,
        salt: Uint8List.fromList(utf8.encode('short')), // 5 chars, < 8
        argon2Iterations: 3,
        argon2Memory: 65536,
        argon2Parallelism: 4,
        pbkdf2Iterations: 1000,
      );

      // We expect this to throw because HashingLogic now has the explicit check again.
      expect(() async => await HashingLogic.hashInput(params), throwsA(isA<Exception>()));
    });

    test('Number system conversion: Hex', () {
      final bytes = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello" in bytes
      final result = HashingLogic.formatBytes(bytes, NumberSystem.hex);
      expect(result, '48656c6c6f');
    });

    test('Number system conversion: Base64', () {
      final bytes = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
      final result = HashingLogic.formatBytes(bytes, NumberSystem.base64);
      expect(result, 'SGVsbG8=');
    });

    test('Entropy calculation for Hex', () {
      final text = '48656c6c6f'; // 10 chars
      // 10 * log2(16) = 10 * 4 = 40
      final entropy = HashingLogic.calculateEntropy(text, NumberSystem.hex);
      expect(entropy, 40.0);
    });

    test('Truncation logic', () {
      final text = 'abcdefghij';
      expect(HashingLogic.truncateOutput(text, 5), 'abcde');
      expect(HashingLogic.truncateOutput(text, 15), 'abcdefghij');
      expect(HashingLogic.truncateOutput(text, 0), 'abcdefghij');
    });
  });
}
